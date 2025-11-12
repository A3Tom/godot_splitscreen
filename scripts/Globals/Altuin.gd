extends Node

enum SceneName {
	MAIN_MENU,
	PLAYER_SELECT,
	CRASH_TEST_LEVEL
}

const SCENE_MAP = {
	SceneName.MAIN_MENU: "res://scenes/MainMenu.tscn",
	SceneName.PLAYER_SELECT: "res://scenes/Menus/PlayerSetup.tscn",
	SceneName.CRASH_TEST_LEVEL: "res://scenes/World.tscn"
}

func _ready():
	print("The great turtle lives!")
	GlobalSignals.register_playable_character.emit('Rinkus', preload("res://scenes/characters/Mage.tscn"))
	GlobalSignals.register_playable_character.emit('Joobly', preload("res://scenes/characters/Druid.tscn"))
	GlobalSignals.register_playable_character.emit('Kloompa', preload("res://scenes/characters/Rogue.tscn"))

func get_scene_path(scene_name: SceneName) -> String:
	return SCENE_MAP.get(scene_name, "")
