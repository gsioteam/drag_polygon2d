tool
extends Control

const Handler = preload("res://addons/drag_polygon2d/lib/handler.tscn")

var target: Polygon2D
var polygon2d: Polygon2D
var content: Control
var container: Control
var canvas

var handlers = []

var undo_redo: UndoRedo

var _dragging = false
var _old_position

func set_target(target):
	self.target = target
	
	if target == null:
		visible = false
		return
	polygon2d.texture = target.texture
	polygon2d.texture_offset = target.texture_offset
	polygon2d.texture_rotation = target.texture_rotation
	polygon2d.texture_scale = target.texture_scale
	polygon2d.polygon = target.polygon
	polygon2d.polygons = target.polygons
	polygon2d.uv = target.uv
	
	_updatePoints()

# Called when the node enters the scene tree for the first time.
func _ready():
	polygon2d = $vbox/container/content/polygon
	content = $vbox/container/content
	container = $vbox/container
	canvas = $vbox/container/content/polygon/canvas

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _updatePoints():
	for handler in handlers:
		handler.queue_free()
	handlers.clear()
	var min_vec: Vector2
	var max_vec: Vector2
	var init = false
	var index = 0
	for vec in polygon2d.polygon:
		if not init:
			min_vec = vec
			max_vec = vec
			init = true
		else:
			if vec.x < min_vec.x:
				min_vec.x = vec.x
			if vec.y < min_vec.y:
				min_vec.y = vec.y
			if vec.x > max_vec.x:
				max_vec.x = vec.x
			if vec.y > max_vec.y:
				max_vec.y = vec.y
		var handle = Handler.instance()
		handle.rect_position = vec
		polygon2d.add_child(handle)
		handlers.push_back(handle)
		handle.data = {
			"index": index
		}
		index+=1
		handle.connect("drag", self, "_on_drag")
		handle.connect("drag_begin", self, "_on_drag_begin")
		handle.connect("drag_end", self, "_on_drag_end")
	
	content.rect_scale = Vector2(2, 2)
	polygon2d.position = Vector2(- (min_vec.x + max_vec.x)/2, - (min_vec.y + max_vec.y)/2)

func _on_drag(data, offset):
	var index = data.index
	offset.x = offset.x / content.rect_scale.x
	offset.y = offset.y / content.rect_scale.y
	var old = polygon2d.polygon[index]
	var vec = old + offset
	_set_point(vec, index)

var _begin_position

func _on_drag_begin(data):
	var index = data.index
	_begin_position = polygon2d.polygon[index]
	
func _on_drag_end(data):
	var index = data.index
	var pos = polygon2d.polygon[index]
	undo_redo.create_action("Drag Point")
	undo_redo.add_do_method(self, "_set_point", pos, index)
	undo_redo.add_undo_method(self, "_set_point", _begin_position, index)
	undo_redo.commit_action()

func _on_container_gui_input(event):
	var zoom_pos
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				content.rect_scale = content.rect_scale * (1 + event.factor / 10)
			if event.button_index == BUTTON_WHEEL_DOWN:
				content.rect_scale = content.rect_scale * (1 - event.factor / 10)
		if event.button_index == BUTTON_MIDDLE:
			_dragging = event.is_pressed()
			_old_position = event.global_position
	if event is InputEventMouseMotion:
		if _dragging:
			content.rect_position += (event.global_position - _old_position)
			_old_position = event.global_position
			
func _on_container_visibility_changed():
	content.rect_position = container.rect_size / 2

func _set_point(point, index):
	polygon2d.polygon[index] = point
	handlers[index].rect_position = point
	target.polygon = polygon2d.polygon
	canvas.update()
