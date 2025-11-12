extends Control

@export var character_name_label: Label
@export var player_id: int = 0

func _ready():
	set_label_default()
	GlobalSignals.character_selection_hover.connect(_on_character_selection_hover)
	GlobalSignals.player_removed.connect(_on_player_removed)


func _on_character_selection_hover(_player_id, character_id):
	if _player_id != player_id:
		return
	
	var character = Sentinel.playable_characters[character_id]
	character_name_label.text = character["name"]

func _on_player_removed(_player_id):
	if _player_id != player_id:
		return
	set_label_default()

func set_label_default():
	character_name_label.text = "Select Character"
