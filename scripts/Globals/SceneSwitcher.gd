# File: SceneSwitcher.gd
# Engine: Godot 4.x
# Usage:
#   1) Project Settings → Autoload → Path: res://SceneSwitcher.gd, Node Name: SceneSwitcher, Add
#   2) SceneSwitcher.change_scene("res://scenes/Level1.tscn", {"player_hp": 100})
#   3) SceneSwitcher.go_back()
#   4) SceneSwitcher.reload_current()

extends CanvasLayer
class_name SceneManager

signal scene_will_change(to_path: String)
signal scene_changed(to_path: String)
signal scene_change_failed(to_path: String, error: String)

## CONFIG ---------------------------------------------------------

# Transition
@export var fade_duration: float = 0.25
@export var fade_on_start: bool = true

# Caching
@export var cache_enabled: bool = true
@export var cache_max_scenes: int = 6 # simple LRU cap

# Optional: pause the game during transitions
@export var pause_during_switch: bool = true

## STATE ----------------------------------------------------------

var _fade_rect: ColorRect
var _tween: Tween
var _is_switching := false

var _current_path: String = ""
var _back_stack: Array[String] = []

var _cache: Dictionary = {} # path -> PackedScene
var _cache_order: Array[String] = [] # LRU order (most recent at end)

## LIFECYCLE ------------------------------------------------------

func _ready() -> void:
	# Fullscreen fade layer (on top: CanvasLayer)
	layer = 128
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1.0) # start black, we'll fade in
	_fade_rect.anchor_left = 0
	_fade_rect.anchor_top = 0
	_fade_rect.anchor_right = 1
	_fade_rect.anchor_bottom = 1
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

	if fade_on_start:
		_fade_to(0.0, fade_duration)
	else:
		_fade_rect.modulate.a = 0.0

## PUBLIC API -----------------------------------------------------

func change_scene(path: String, data: Dictionary = {}, push_to_backstack: bool = true) -> void:
	"""
	Change scenes with fade + threaded loading.
	`data` will be offered to the new scene via:
	  - _apply_scene_data(data: Dictionary) if present, else
	  - setting 'scene_data' property if present.
	"""
	if _is_switching:
		return
	_is_switching = true

	if pause_during_switch:
		get_tree().paused = true

	emit_signal("scene_will_change", path)
	await _fade_to(1.0, fade_duration)

	# Capture current path for back stack
	if push_to_backstack and _current_path != "" and _current_path != path:
		_back_stack.push_back(_current_path)

	var packed = await _get_packed_scene(path)
	if packed == null:
		# Failed to load – revert fade and unpause
		await _fade_to(0.0, fade_duration)
		if pause_during_switch:
			get_tree().paused = false
		_is_switching = false
		emit_signal("scene_change_failed", path, "Failed to load PackedScene.")
		push_warning("[SceneSwitcher] Failed to load: %s" % path)
		return

	# Instantiate and hand off data
	var inst = packed.instantiate()

	# Offer data in a flexible way
	if " _apply_scene_data" in inst: # spelled with leading space? avoid; use has_method
		# (kept for safety; actual check below)
		pass
	if inst.has_method("_apply_scene_data"):
		inst._apply_scene_data(data)
	elif inst.has_variable("scene_data"):
		inst.set("scene_data", data)

	# Swap scene
	var tree := get_tree()
	var current := tree.current_scene
	tree.root.add_child(inst)
	tree.current_scene = inst
	if current:
		current.queue_free()

	_current_path = path

	await _fade_to(0.0, fade_duration)
	if pause_during_switch:
		get_tree().paused = false

	_is_switching = false
	emit_signal("scene_changed", path)

func go_back(data: Dictionary = {}) -> void:
	"""
	Go back to the previous scene in the stack (if any).
	"""
	if _back_stack.is_empty():
		return
	var prev = _back_stack.pop_back()
	change_scene(prev, data, false)

func reload_current(data: Dictionary = {}) -> void:
	"""
	Reload the current scene (does not push to back stack).
	"""
	if _current_path == "":
		return
	change_scene(_current_path, data, false)

func clear_back_stack() -> void:
	_back_stack.clear()

func get_history() -> Array[String]:
	return _back_stack.duplicate()

func get_current_path() -> String:
	return _current_path

func warm_cache(paths: Array[String]) -> void:
	"""
	Preload a list of scenes into the cache (non-blocking, threads).
	"""
	for p in paths:
		# Fire and forget; cache fills as requests complete
		_get_packed_scene(p, true)

func clear_cache() -> void:
	_cache.clear()
	_cache_order.clear()

## INTERNAL: LOADING & CACHE -------------------------------------

func _touch_cache_order(path: String) -> void:
	_cache_order.erase(path)
	_cache_order.push_back(path)
	# Enforce LRU size
	while _cache_order.size() > cache_max_scenes:
		var evict = _cache_order.pop_front()
		_cache.erase(evict)

func _put_cache(path: String, packed: PackedScene) -> void:
	if not cache_enabled:
		return
	_cache[path] = packed
	_touch_cache_order(path)

func _get_from_cache(path: String) -> PackedScene:
	if not cache_enabled:
		return null
	if _cache.has(path):
		_touch_cache_order(path)
		return _cache[path]
	return null

func _get_packed_scene(path: String, warm_only: bool = false):
	"""
	Threaded load helper. If warm_only, it kicks off a load and returns immediately.
	When not warm_only, returns a PackedScene (awaitable via signal-to-value pattern).
	"""
	var cached := _get_from_cache(path)
	if cached:
		if warm_only:
			return Signal() # dummy
		return cached

	# If already requested, status will reflect that; it's fine to re-request.
	var err := ResourceLoader.load_threaded_request(path, "PackedScene")
	if err != OK and err != ERR_BUSY:
		if warm_only:
			return Signal()
		return null

	if warm_only:
		return Signal()

	# Poll until ready
	while true:
		var progress := []
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var res := ResourceLoader.load_threaded_get(path)
			if res is PackedScene:
				_put_cache(path, res)
				return res
			return null
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			return null
		await get_tree().process_frame # yield to main loop while loading

## INTERNAL: TRANSITION -------------------------------------------

func _fade_to(target_alpha: float, duration: float) -> Signal:
	if is_instance_valid(_tween):
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_fade_rect, "modulate:a", target_alpha, duration)
	return _tween.finished
