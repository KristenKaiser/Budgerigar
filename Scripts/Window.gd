extends Node

var xMax
var xMin
var yMax
var yMin

func _ready():
	setWindowEdges()
	
func setWindowEdges() :
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	var rect = viewport.get_visible_rect()
	xMax = ((rect.size.x / 2 /camera.get_zoom().x) + rect.position.x) as int
	xMin = (-(rect.size.x / 2 /camera.get_zoom().x) + rect.position.x) as int
	yMax = ((rect.size.y / 2 /camera.get_zoom().y) + rect.position.y) as int
	yMin = (-(rect.size.y / 2 /camera.get_zoom().y) + rect.position.y) as int
