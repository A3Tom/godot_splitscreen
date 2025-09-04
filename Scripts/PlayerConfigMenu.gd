extends Control

@export_category("Player 1 UI Config")
@export var p1_JoinUI: CanvasItem
@export var p1_CharacterSelectUI: CanvasItem
@export var p1_LobbyUI: CanvasItem

@export_category("Player 2 UI Config")
@export var p2_JoinUI: CanvasItem
@export var p2_CharacterSelectUI: CanvasItem
@export var p2_LobbyUI: CanvasItem

enum PlayerJoinState {
	WAITING_FOR_JOIN,
	CHARACTER_SELECT,
	LOBBY
}
@onready var player_ui_status: Dictionary = {
	0: PlayerJoinState.WAITING_FOR_JOIN,
	1: PlayerJoinState.WAITING_FOR_JOIN
}
@onready var player_character_map: Dictionary = {
	0: 0,
	1: 0
}

func _ready():
	GlobalSignals.character_selection_hover.connect(_on_character_selection_hover)
	show_join_ui(0)
	show_join_ui(1)

func _input(event):
	if event is InputEventJoypadMotion and event.axis_value < 0.1 or event is InputEventMouse:
		return

	print("Input event: ", event)
	print("device: ", event.device)
	if not event is InputEventJoypadButton:
		return

	print("Event was valid")
	var player_id = get_player_id(event.device)
	var player_ui_state = player_ui_status.get(player_id, null)
	print("Player ID: ", player_id, " UI State: ", player_ui_state)

	if player_ui_state == PlayerJoinState.WAITING_FOR_JOIN:
		handle_input_waiting_for_join(player_id, event)
	elif player_ui_state == PlayerJoinState.CHARACTER_SELECT:
		handle_input_character_select(player_id, event)
	elif player_ui_state == PlayerJoinState.LOBBY:
		handle_input_lobby(player_id, event)

func _on_character_selection_hover(player_id, character_id):
	player_character_map[player_id] = character_id
	
func isValidInput(event):
	return event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")

func get_player_id(device_id):
	var player_id = Sentinel.get_player_by_device(device_id)
	return player_id if player_id != null else Sentinel.get_next_player_id()

func handle_input_waiting_for_join(player_id, event):
	if event.is_action_pressed("ui_accept"):
		GlobalSignals.player_added.emit(player_id, event.device)
		player_ui_status[player_id] = PlayerJoinState.CHARACTER_SELECT
		show_character_select_ui(player_id)

func handle_input_character_select(player_id, event):
	if event.is_action_pressed("ui_accept"):
		GlobalSignals.player_character_changed.emit(player_id, event.device)
		player_ui_status[player_id] = PlayerJoinState.LOBBY
		show_lobby_ui(player_id)
	elif event.is_action_pressed("ui_cancel"):
		GlobalSignals.player_removed.emit(player_id)
		player_ui_status[player_id] = PlayerJoinState.WAITING_FOR_JOIN
		show_join_ui(player_id)
	elif event.is_action_pressed("ui_left"):
		print("Left pressed")
		var previous_character_id = get_previous_character_id(player_id)
		print("Previous character ID: ", previous_character_id)
		GlobalSignals.character_selection_hover.emit(player_id, previous_character_id)
		pass
	elif event.is_action_pressed("ui_right"):
		print("Right pressed")
		var next_character_id = get_next_character_id(player_id)
		print("Next character ID: ", next_character_id)
		GlobalSignals.character_selection_hover.emit(player_id, next_character_id)
	else:
		print("Unhandled input in character select: ", event)


func handle_input_lobby(player_id, event):
	if event.is_action_pressed("ui_cancel"):
		player_ui_status[player_id] = PlayerJoinState.CHARACTER_SELECT
		show_character_select_ui(player_id)
	elif event.is_action_pressed("ui_start"):
		print("Player %d is ready!" % player_id)
		if is_everyone_ready():
			print("All players are ready! Starting game...")
			var next_scene = Altuin.get_scene_path(Altuin.SceneName.CRASH_TEST_LEVEL)
			get_tree().change_scene_to_file(next_scene)
	else:
		print("Unhandled input in lobby: ", event)

func get_previous_character_id(player_id):
	var character_id = player_character_map[player_id]
	if character_id == 0:
		return Sentinel.playable_characters.size() - 1
	else:
		return character_id - 1

func get_next_character_id(player_id):
	var character_id = player_character_map[player_id]
	if character_id == Sentinel.playable_characters.size() - 1:
		return 0
	else:
		return character_id + 1

func show_join_ui(player_id):
	hide_player_ui(player_id)
	if player_id == 0:
		p1_JoinUI.visible = true
	elif player_id == 1:
		p2_JoinUI.visible = true

func show_character_select_ui(player_id):
	hide_player_ui(player_id)
	if player_id == 0:
		p1_CharacterSelectUI.visible = true
	elif player_id == 1:
		p2_CharacterSelectUI.visible = true

func show_lobby_ui(player_id):
	hide_player_ui(player_id)
	if player_id == 0:
		p1_LobbyUI.visible = true
	elif player_id == 1:
		p2_LobbyUI.visible = true

func hide_player_ui(player_id):
	if player_id == 0:
		p1_JoinUI.visible = false
		p1_CharacterSelectUI.visible = false
		p1_LobbyUI.visible = false
	elif player_id == 1:
		p2_JoinUI.visible = false
		p2_CharacterSelectUI.visible = false
		p2_LobbyUI.visible = false

func is_everyone_ready():
	for player_id in player_ui_status.keys():
		if player_ui_status[player_id] == PlayerJoinState.CHARACTER_SELECT:
			return false
	return true
