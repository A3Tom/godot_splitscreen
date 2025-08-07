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

func _ready():
	show_join_ui(0)
	show_join_ui(1)

func _input(event):
	if (!isValidInput(event) or event.is_echo()):
		return

	var player_id = get_player_id(event.device)
	var player_ui_state = player_ui_status.get(player_id, null)

	if player_ui_state == PlayerJoinState.WAITING_FOR_JOIN:
		handle_input_waiting_for_join(player_id, event)
	elif player_ui_state == PlayerJoinState.CHARACTER_SELECT:
		handle_input_character_select(player_id, event)
	elif player_ui_state == PlayerJoinState.LOBBY:
		handle_input_lobby(player_id, event)

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
		GlobalSignals.player_device_changed.emit(player_id, event.device)
		player_ui_status[player_id] = PlayerJoinState.LOBBY
		show_lobby_ui(player_id)
	elif event.is_action_pressed("ui_cancel"):
		GlobalSignals.player_removed.emit(player_id)
		player_ui_status[player_id] = PlayerJoinState.WAITING_FOR_JOIN
		show_join_ui(player_id)
	elif event.is_action_pressed("ui_left"):
		# Handle character selection logic here if needed
		pass
	elif event.is_action_pressed("ui_right"):
		# Handle character selection logic here if needed
		pass

func handle_input_lobby(player_id, event):
	if event.is_action_pressed("ui_cancel"):
		player_ui_status[player_id] = PlayerJoinState.CHARACTER_SELECT
		show_character_select_ui(player_id)

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
