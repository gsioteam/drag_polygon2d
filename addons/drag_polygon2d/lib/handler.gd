tool
extends Control

var data

var handler: Control

signal drag(data, offset)

var _old_position
var mouse_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	handler = $button

func _on_button_button_down():
	mouse_down = true
	_old_position = null

func _on_button_button_up():
	mouse_down = false


func _on_button_gui_input(event):
	if mouse_down and event is InputEventMouseMotion:
		if _old_position == null:
			_old_position = event.global_position
		else:
			emit_signal("drag", data, event.global_position - _old_position)
			_old_position = event.global_position
