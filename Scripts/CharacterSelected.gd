extends Node3D

@export var spotlight_colour: Color
@export var player_id: int = 0

@onready var character_spawn_point: Node3D = %CharacterSpawnPoint
@onready var colourful_spotlight: SpotLight3D = %ColourfulSpotlight

func _ready():
	GlobalSignals.character_selection_hover.connect(_on_character_selection_hover)
	GlobalSignals.player_removed.connect(_on_player_removed)
	GlobalSignals.player_added.connect(_on_player_added)
	colourful_spotlight.light_color = spotlight_colour

func _on_character_selection_hover(_player_id, character_id):
	if _player_id != player_id:
		return
	
	var character_scene = Sentinel.playable_characters[character_id]["scene"]
	if character_scene:
		clear_selected_character()
		spawn_character(character_scene)

func _on_player_added(_player_id, device_id):
	if _player_id == player_id:
		colourful_spotlight.visible = true
	
func _on_player_removed(_player_id):
	if _player_id != player_id:
		return

	clear_selected_character()
	colourful_spotlight.visible = false

func clear_selected_character():
	var character = character_spawn_point.get_child(0)
	character_spawn_point.remove_child(character)

func spawn_character(character_scene):
	var selected_character = character_scene.instantiate()
	character_spawn_point.add_child(selected_character)
