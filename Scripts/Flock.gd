
extends Node
#class_name Flock
const maxFlockSize = 256
const spawnDistanceHalf_I = 9
const bird_O = preload("res://Scenes/budgie.tscn")
"res://Scenes/node_2d_budgie.tscn"
const birdScript = preload("res://Scripts/budgie.gd")
const xWindowMarginRatio = 0.25
const yWindowMarginRatio = 0.25
@onready var window = %Window
var countBudgies_I = 512
var array: Array[Node]
const velocityMin = -1.5
const velocityMax = 1.5
var flockCenter : Vector2 = Vector2(0,0)
var centerDot



func getFlockArray() -> Array[Node] :
	return array
	
func _ready():
	#setWindowEdges()
	for i in countBudgies_I: 
		createBirds(i)		


func createBirds(id):
	var inst = bird_O.instantiate()
	inst.set_script(birdScript)
	inst.id = id
	add_child(inst)
	array.push_back(inst)
	inst.body.position = randPosition()
	inst.position = inst.body.position
	inst.body.set_velocity(randVelocity())
	inst.velocity = inst.body.get_velocity()
	inst.acceleration = inst.velocity
	
func randVelocity():
	return Vector2((randf() * ( velocityMax - velocityMin) ) + velocityMin, (randf() * ( velocityMax - velocityMin) ) + velocityMin)
	
func randRotation():
	return randi() % 360 + 1

func randPosition():
	var x = 0
	var y = 0 
	var randCoordinates
	var isTooClose = false
	while true:
		isTooClose = false
		var xMin: int = window.xMin - (window.xMin * xWindowMarginRatio)
		var xMax: int = window.xMax - (window.xMax * xWindowMarginRatio)
		var yMin: int = window.yMin - (window.yMin * yWindowMarginRatio)
		var yMax: int = window.yMax - (window.yMax * yWindowMarginRatio)
		
		x = randi() % (xMax - xMin) + xMin
		y = randi() % (yMax - yMin) + yMin
		randCoordinates = Vector2(x, y)
		
		# if coordinates are too close to another bird then generate new coordinates
		for bird in array:
			var sub = (bird.body.position - randCoordinates).abs()
			var distance = (sub.x + sub.y)/2
			if distance < (spawnDistanceHalf_I + 1):
				isTooClose = true
		if isTooClose == false:
			break
	return Vector2(x, y)
	
func getCenter() -> Vector2:
	var sum: Vector2 = Vector2(0,0)
	var total = 0.0
	for bird in array:
		sum += bird.body.position
		total += 1
	sum = sum/total
	return sum
	
