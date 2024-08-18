extends Camera2D
@onready var flock = %Flock

var maxZoom = Vector2(4.0,4.0)
var minZoom = Vector2(0.0,0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = flock.getCenter()
	zoomCamera()


func zoomCamera():
	var flockSize = flock.array.size()

