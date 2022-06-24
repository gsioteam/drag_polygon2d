tool
extends EditorPlugin

const Polygon2DEditorPanel = preload("res://addons/drag_polygon2d/lib/polygon2d_editor.tscn")

var editor_pannel

func _enter_tree():
	editor_pannel = Polygon2DEditorPanel.instance()
	editor_pannel.undo_redo = get_undo_redo()
	add_control_to_bottom_panel(editor_pannel, "Polygon2D")
	get_editor_interface().get_selection().connect("selection_changed", self, "_on_selection_changed")
	make_visible(false)

func _exit_tree():
	if editor_pannel:
		remove_control_from_bottom_panel(editor_pannel)
		editor_pannel.queue_free()

func make_visible(visible):
	if editor_pannel and visible:
		make_bottom_panel_item_visible(editor_pannel)

func handles(object):
	if object is Polygon2D:
		return not object.polygon.empty()
	return false

func get_plugin_name():
	return "Polygon2D"
	
func get_plugin_icon():
	var gui = get_editor_interface().get_base_control()
	return gui.get_icon("Polygon2D", "EditorIcons")

func _on_selection_changed():
	if editor_pannel == null:
		return
	var nodes = get_editor_interface().get_selection().get_selected_nodes()
	var target
	if nodes.size() == 1 and nodes[0] is Polygon2D:
		target = nodes[0]
	editor_pannel.set_target(target)
	
func apply_changes():
	pass

