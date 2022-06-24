tool
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	var p2d = get_parent()
	if p2d is Polygon2D:
		var polygon: PoolVector2Array = p2d.polygon
		var polygons: Array = p2d.polygons
		for face in polygons:
			var points = PoolVector2Array()
			var colors = PoolColorArray()
			var color = Color.blue
			color.a = 0.2
			for idx in face:
				points.append(polygon[idx])
				colors.append(color)
			draw_polygon(points, colors)
			points.append(polygon[face[0]])
			draw_polyline(points, Color.blue, 2)
