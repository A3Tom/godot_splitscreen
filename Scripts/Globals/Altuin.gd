extends Node

enum SceneName {
    MAIN_MENU,
    PLAYER_SELECT,
    CRASH_TEST_LEVEL
}

const SCENE_MAP = {
    SceneName.MAIN_MENU: "res://scenes/MainMenu.tscn",
    SceneName.PLAYER_SELECT: "res://scenes/PlayerSetup.tscn",
    SceneName.CRASH_TEST_LEVEL: "res://scenes/CrashTestLevel.tscn"
}

func _ready():
    print("The great turtle lives!")
    GlobalSignals.register_playable_character.emit('Rinkus', preload("res://scenes/Characters/Mage.tscn"))
    GlobalSignals.register_playable_character.emit('Joobly', preload("res://scenes/Characters/Druid.tscn"))
    GlobalSignals.register_playable_character.emit('Kloompa', preload("res://scenes/Characters/Rogue.tscn"))