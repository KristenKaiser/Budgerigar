extends Node

const speed = 5
const minForce = -1.0
const maxForce= 1.0
const maxVelocity : Vector2 = Vector2(5,5)
const negMaxVelocity : Vector2 = Vector2(-5, -5)
const minVelocity = .5
var id
var body
var sprite
var shadow
var shadowOffset : Vector2 = Vector2(0, 140)
var perception = 128
var perceptionSquared = perception * perception
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
var oldAcceleration = Vector2.ZERO
var autopilot = true
var lastMousePosition = Vector2(64.0, 0.0)
var baseAnimSpeed = 1.5
var animScale = 0.25
var id_mod_4

func _ready():
	id_mod_4 = id % 4
	body = find_child("body")
	sprite = find_child("sprite")
	shadow = body.find_child("Shadow")
	
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	
	#sprite.set_speed_scale(0.9+(randf()*0.2))
	
func _process(delta):
	if Engine.get_physics_frames() % 4 == id_mod_4:
		acceleration = getAcceleration()
		velocity += acceleration * delta * speed
	velocity = velocity.clamp(negMaxVelocity, maxVelocity)
	setRotation()
	body.position += velocity
	sprite.set_speed_scale(baseAnimSpeed-(velocity.length()*animScale)+(randf()*0.1))
	moveShadow()

func getAcceleration() -> Vector2:
	var friends = findFriends()
	return (cohesion(friends).normalized() * cohesionStrength +
			align(friends).normalized() * alignStrength +
			seperation(friends).normalized() * seperationStrength +
			chaseMouse().normalized() * mouseStrength).normalized()

func findFriends() -> Array:
	var flockArray = get_parent().array
	return flockArray.filter(func(friend): 
		return friend != self and body.position.distance_squared_to(friend.body.position) < perceptionSquared
	)

func align(friends):
	var steering = Vector2.ZERO
	var total = 0
	for friend in friends:
		var dist = body.position.distance_squared_to(friend.body.position)
		if abs(dist) < alignPerception:
			steering += friend.body.velocity
			total += 1
	if total == 0: 
		return acceleration
	steering = Vector2(steering / total)
	steering -= velocity
	return steering

func cohesion(friends):
	var steering = Vector2.ZERO
	var total = 0
	for friend in friends:
		var dist = body.position.distance_squared_to(friend.body.position)
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
	var steering = Vector2.ZERO
	var total = 0
	for friend in friends:
		var dist = body.position.distance_squared_to(friend.body.position)
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
	var steering = Vector2.ZERO
	if Input.is_mouse_button_pressed( MOUSE_BUTTON_LEFT ):
		mousePos = get_viewport().get_mouse_position() - halfRect
		lastMousePosition = mousePos
	
	mousePos += get_parent().getCenter() 
	var dist = body.position.distance_squared_to(mousePos)
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
