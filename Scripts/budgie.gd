extends Node

const speed = 5
const minForce = -1.0
const maxForce= 1.0
const maxVelocity : Vector2 = Vector2(5,5)
const minVelocity = .5
var id
var body
var shadow
var shadowOffset : Vector2 = Vector2(0, 140)
var perception = 128
var seperationPerception = 8
var cohesionPerception = 128
var alignPerception = 64
var position
var velocity 
var acceleration
var cohesionStrength = 1.0
var alignStrength = 1.0
var seperationStrength = 10.0
var mouseStrength = 8.0
var oldAcceleration = Vector2(0,0)
var autopilot = true
var lastMousePosition = Vector2(64.0, 0.0)

func _ready():

	body = find_child("body")
	shadow = body.find_child("Shadow")
	
	position = Vector2(0,0)
	velocity = Vector2(0,0)
	
func _process(delta):
	if Engine.get_process_frames() % 4 == 0 && id % 4 == 0 \
	|| Engine.get_process_frames() % 4 == 1 && id % 4 == 1 \
	|| Engine.get_process_frames() % 4 == 2 && id % 4 == 2 \
	|| Engine.get_process_frames() % 4 == 3 && id % 4 == 3 :
		acceleration = getAcceleration()	
		velocity += acceleration * delta * speed
	velocity = velocity.clamp(-maxVelocity, maxVelocity)
	setRotation()
	position += velocity
	body.position = position 
	body.velocity = velocity
	moveShadow()

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
		var dist = body.position.distance_to(friend.body.position)
		if abs(dist) < alignPerception:
			steering += friend.body.velocity
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	steering -= velocity
	return steering

func cohesion(friends):
	var steering = Vector2(0,0)
	var total = 0
	for friend in friends:
		var dist = body.position.distance_to(friend.body.position)
		if abs(dist) < alignPerception:
			steering += friend.body.position
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	steering -= position
	steering /= perception 
	steering -= velocity
	return steering
	
func seperation(friends):
	var steering = Vector2(0,0)
	var total = 0
	for friend in friends:
		var dist = body.position.distance_to(friend.body.position)
		if abs(dist) < seperationPerception:
			var diff = body.position - friend.body.position
			diff = diff/dist
			steering += diff
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	steering -= velocity
	return steering
	
func chaseMouse():
	var mousePos = lastMousePosition
	var viewport = get_viewport()
	var rect = viewport.get_visible_rect()
	var halfRect = rect.size / 2
	var steering = Vector2(0,0)
	if Input.is_mouse_button_pressed( MOUSE_BUTTON_LEFT ):
		mousePos = get_viewport().get_mouse_position() - halfRect
		lastMousePosition = mousePos
	
	mousePos += get_parent().getCenter() 
	var dist = body.position.distance_to(mousePos)
	var diff = mousePos - body.position 
	steering = diff/dist
	var randStrength = randf() * mouseStrength
	steering = steering.clamp(Vector2(minForce * mouseStrength , minForce * mouseStrength ), Vector2(maxForce * mouseStrength , maxForce * mouseStrength ))
	return steering

func setRotation():
	body.rotation = velocity.angle() + deg_to_rad(90.0)
	
func moveShadow():
	pass
	#print((velocity.normalized() ))
	shadow.set_global_position(body.global_position + shadowOffset)
