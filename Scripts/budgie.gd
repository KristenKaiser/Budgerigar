extends Node
#extends  Flock
#class_name Budgie

const speed = 5

const minForce = -1.0
const maxForce= 1.0
const maxVelocity : Vector2 = Vector2(5,5)
#const maxSpeed = 5
var id
var body
var perception = 64
var seperationPerception = 16
#var cohesionPerception = 128

var position
var velocity 
var acceleration
var cohesionStrength = 1.0
var alignStrength = 1.0
var seperationStrength = 2.0
var mouseStrength = 1.0

#var cohesionPerception = 64
#var alignPerception = 64


var oldAcceleration = Vector2(0,0)
var autopilot = true
var lastMousePosition = Vector2(64.0, 0.0)

func _ready():
	body = find_child("body")
	position = Vector2(0,0)
	velocity = Vector2(0,0)
	
#func _physics_process(delta):
func _process(delta):
	if Engine.get_process_frames() % 4 == 0 && id % 4 == 0 \
	|| Engine.get_process_frames() % 4 == 1 && id % 4 == 1 \
	|| Engine.get_process_frames() % 4 == 2 && id % 4 == 2 \
	|| Engine.get_process_frames() % 4 == 3 && id % 4 == 3 :
		acceleration = getAcceleration()	
		velocity += acceleration * delta * speed
		#print(velocity)
	velocity = velocity.clamp(-maxVelocity, maxVelocity)
	setRotation()
	position += velocity
	body.position = position 
	body.velocity = velocity

func getAcceleration() -> Vector2:
	var friends = findFriends()
	var acc = Vector2(0.0,0.0)
	acc += cohesion(friends).normalized() * cohesionStrength
	acc += align(friends) .normalized() * alignStrength
	acc += seperation(friends).normalized() * seperationStrength
	acc += chaseMouse().normalized() * mouseStrength
	acc = acc.normalized()
	return acc

func findFriends():
	var flockArray = get_parent().array
	var friends = []
	for friend in flockArray:
		var dist = body.position.distance_to(friend.body.position)
		if friend != self && abs(dist) < perception:
			friends.push_back(friend)
	return friends

func align(friends):
	var steering = Vector2(0,0)
	var total = 0
	for friend in friends:
			steering += friend.body.velocity
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	#steering *= alignStrength
	steering -= velocity
	steering = steering.clamp(Vector2(minForce * alignStrength, minForce * alignStrength), Vector2(maxForce * alignStrength, maxForce * alignStrength))
	return steering

func cohesion(friends):
	var steering = Vector2(0,0)
	var total = 0
	for friend in friends:
		steering += friend.body.position
		total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	steering -= position
	steering /= perception 
	#steering *= cohesionStrength
	steering -= velocity
	steering = steering.clamp(Vector2(minForce * cohesionStrength, minForce * cohesionStrength), Vector2(maxForce * cohesionStrength, maxForce * cohesionStrength))
	return steering
	
	
func seperation(friends):
	var steering = Vector2(0,0)
	var total = 0
	for friend in friends:
		var dist = body.position.distance_to(friend.body.position)
		if friend != self && abs(dist) < seperationPerception:
			var diff = body.position - friend.body.position
			diff = diff/dist
			steering += diff
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	#steering *= seperationStrength 
	steering -= velocity
	steering = steering.clamp(Vector2(minForce * seperationStrength , minForce * seperationStrength ), Vector2(maxForce * seperationStrength , maxForce * seperationStrength ))
	return steering
	
func chaseMouse():
	var mousePos = lastMousePosition
	var viewport = get_viewport()
	var rect = viewport.get_visible_rect()
	var halfRect = rect.size / 2
	var steering = Vector2(0,0)
	if Input.is_mouse_button_pressed( MOUSE_BUTTON_LEFT ):
		#autopilot = false
		mousePos = get_viewport().get_mouse_position() - halfRect
		lastMousePosition = mousePos
	
	mousePos += get_parent().getCenter() 
	var dist = body.position.distance_to(mousePos)
	var diff = mousePos - body.position 
	steering = diff/dist
	var randStrength = randf() * mouseStrength
	#steering *= randStrength
	steering = steering.clamp(Vector2(minForce * mouseStrength , minForce * mouseStrength ), Vector2(maxForce * mouseStrength , maxForce * mouseStrength ))
	return steering

		
func setRotation():
	body.rotation = velocity.angle() + deg_to_rad(90.0)
	
		
		

	
