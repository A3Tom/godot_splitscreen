extends Control

@export var pause_buttons: Array[Button] = []

var current_button_index: int = 0

func _ready():
	if pause_buttons.size() > 0:
		set_hovered_button(0)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		hide()
	elif event.is_action_pressed("ui_accept"):
		pause_buttons[current_button_index].emit_signal("pressed")

func set_hovered_button(index: int):
	current_button_index = index
	pause_buttons[current_button_index].grab_focus()
