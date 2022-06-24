tool
extends Control

var data

var handler: Control

signal drag(data, offset)
signal drag_begin(data)
signal drag_end(data)

var _old_position
var mouse_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	handler = $button

func _on_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				mouse_down = true
				_old_position = event.global_position
				emit_signal("drag_begin", data)
			else:
				mouse_down = false
				emit_signal("drag_end", data)
	if mouse_down and event is InputEventMouseMotion:
		emit_signal("drag", data, event.global_position - _old_position)
		_old_position = event.global_position
