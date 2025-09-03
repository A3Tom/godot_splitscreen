extends Node

class_name SceneSwitcher

func switch_to_scene(scene_path: String):
    var new_scene = load(scene_path)
    if new_scene:
        get_tree().change_scene_to(new_scene)
    else:
        push_error("Scene not found: " + scene_path)

func reload_current_scene():
    var current_scene = get_tree().current_scene
    if current_scene:
        get_tree().reload_current_scene()
    else:
        push_error("No current scene to reload.")
