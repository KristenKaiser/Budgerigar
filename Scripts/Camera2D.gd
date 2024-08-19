extends Camera2D
@onready var flock = %Flock

var maxZoom = Vector2(5.0, 5.0)
var minZoom = Vector2(1.0,1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	zoomCamera()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = flock.getCenter()
	zoomCamera()


func zoomCamera():
	pass
	#var flockSize = clamp(flock.array.size(), 0, flock.maxFlockSize) as float
	#var zoomScale = 1.0 - (flockSize/flock.maxFlockSize)
	#print(zoomScale)
	#set_zoom(((maxZoom - minZoom) * zoomScale) + minZoom)
