class_name ViewportController extends Node

const PlayerViewportScript = preload("res://scripts/PlayerViewport.gd")

@export var player_cameras = {}

func _ready() -> void:
	build_player_viewports()

func build_player_viewports() -> void:
	var player_count = Sentinel.get_player_count()
	var viewport_size = get_viewport_size(player_count)

	for player in Sentinel.player_device_map.keys():
		var player_viewport = PlayerViewportScript.new()
		player_viewport.name = "Viewport_Player_%d" % player
		player_viewport.set_viewport_size(Vector2i(viewport_size.x / 2, viewport_size.y))
		player_viewport.set_subviewport_size(viewport_size)

		player_viewport.set_subviewport_position(get_viewport_position(player, player_count, viewport_size))
		add_child(player_viewport)
		
		player_cameras[player] = player_viewport.get_camera()

func get_viewport_size(player_count: int) -> Vector2:
	match player_count:
		1: return Vector2(1280, 720)
		2: return Vector2(640, 720)
		4: return Vector2(640, 360)
		_: return Vector2(1280, 720)
	
func get_viewport_position(player_id: int, player_count: int, viewport_size: Vector2) -> Vector2:
	match player_count:
		1: return Vector2(0, 0)
		2: return Vector2((player_id - 1) * viewport_size.x, 0)
		4: return Vector2(((player_id - 1) % 2) * viewport_size.x, ((player_id - 1) / 2) * viewport_size.y)
		_: return Vector2(0, 0)
