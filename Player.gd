extends KinematicBody2D

var speed = Vector2.ZERO
var xDirection = 1
var yDirection = 1
var velocity = Vector2()
var closestPlanet = null
var playerRot = 0
var state = 0 #0 = on planet gravity
var stateDelay = 0
var pickup = false
var pickupObject = null

const MAX_SPEED = 2000
const MAX_VERTICAL_SPEED = 10000
const JUMP_SPEED = 3000
const ACCELERATION = 50
const FRICTION = 0.1
const SPACE_FRICTION = 0.02
const TurnTowards = preload("res://turnTowards.gd")

onready var ANIM = $AnimatedSprite
onready var particleJetUp = $ParticlesJetUp
onready var particleJetRight = $ParticlesJetRight
onready var particleJetLeft = $ParticlesJetLeft
onready var particleJetDown = $ParticlesJetDown
onready var turn_towards = TurnTowards.new()

#Left right dir
enum {
	LEFT = -1,
	RIGHT = 1,
	IDLE = 0
}

#States
enum {
	PLANET = 0,
	SPACE = 1
}

func _ready():
	set_physics_process(true)
	z_index = 100

func _physics_process(delta):
	
	var nextPlanet = get_closest_planet()
	
	#Switch area state
	if(nextPlanet.is_in_gravity_field(get_global_position())):
		state = PLANET
		stateDelay = 20
		
		#If changing planet
		if(nextPlanet != closestPlanet):
			closestPlanet = nextPlanet
			
			#invert y velocity so player moves towards planet centre
			if(speed.y < 0):
				speed.y = -speed.y
			#if(speed.x < 0):
			#	speed.x = -speed.x
	elif(stateDelay == 0):
		state = SPACE

	#Jet Particles
	particleJetRight.emitting = false
	particleJetUp.emitting = false
	particleJetLeft.emitting = false
	particleJetDown.emitting = false

	#State delay allows for the certainty of a state changed. This stops the player jumping
	#between space and planet states at the edge of a planets atmosphere
	if(stateDelay > 0):
		stateDelay -= 1
	
	#movement for space or planet
	match(state):
		PLANET:
			planetState(delta)
		SPACE:
			spaceState(delta)

	#Get up direction so that the floor can be determined based on rotation
	var up_direction = Vector2(sin(playerRot), -cos(playerRot))

	#toggle pickup
	if(Input.is_action_just_pressed("pickup")):
		if(pickupObject != null):
			pickup = !pickup

	#Apply pickup
	if(pickupObject != null):
		if(pickup):
			pickupObject.set_rotation(rotation)
			pickupObject.global_transform.origin = Vector2(0,0)
			$PickupSprite.set_texture(pickupObject.sprite.get_texture())#global_transform.origin = Vector2(globOrigin.x + 10 * sin(playerRot+90), globOrigin.y + 10 * -cos(playerRot+90))
		elif(pickup == false):
			$PickupSprite.set_texture(null)
			pickupObject.global_transform.origin = get_global_transform().get_origin()
			pickupObject = null
		

	#Set rotation and rotation of velocity vector
	velocity = Vector2(speed.x * delta, speed.y * delta)
	velocity = velocity.rotated(playerRot)
	
	#Set player rotation
	set_rotation(playerRot)

	velocity = move_and_slide(velocity, up_direction)

func planetState(delta):
	applyPlanetJump(delta)
	applyPlanetMovement(delta)
	applyPlanetGravity(delta)

	#Rotate player towards planet
	if(closestPlanet):
		var planetT = closestPlanet.gravityCentre.get_global_position()
		var smoothForce = 500
		var smooth = smoothForce/(get_global_position().distance_to(closestPlanet.get_global_position()))
		playerRot = turn_towards.turn_towards(playerRot, get_global_position(), planetT, smooth * delta)
	else:
		playerRot = get_rotation()

func spaceState(delta):
	applySpaceMovement(delta)

func applySpaceMovement(delta):
	var just_pressed_right = Input.is_action_just_pressed("ui_right")
	var just_pressed_left = Input.is_action_just_pressed("ui_left")
	var just_pressed_up = Input.is_action_just_pressed("ui_up")
	var just_pressed_down = Input.is_action_just_pressed("ui_down")
	
	if(just_pressed_right):
		if(xDirection != 1):
			ANIM.frame = 0
		else:
			ANIM.frame = 1
		ANIM.play("Space")
	if(just_pressed_left):
		if(xDirection != -1):
			ANIM.frame = 0
		else:
			ANIM.frame = 1
		ANIM.play("Space")
	if(just_pressed_down or just_pressed_up):
		ANIM.play("Space")

	if(Input.get_action_strength("ui_right")):
		particleJetRight.emitting = true
		xDirection = 1
		speed.x += ACCELERATION * xDirection
	elif(Input.get_action_strength("ui_left")):
		particleJetLeft.emitting = true
		xDirection = -1
		speed.x += ACCELERATION * xDirection
	else:
		speed.x = lerp(speed.x, 0, SPACE_FRICTION)
		
	if(Input.get_action_strength("ui_down")):
		particleJetDown.emitting = true
		yDirection = 1
		speed.y += ACCELERATION * yDirection
	elif(Input.get_action_strength("ui_up")):
		particleJetUp.emitting = true
		
		yDirection = -1
		speed.y += ACCELERATION * yDirection
	else:
		speed.y = lerp(speed.y, 0, SPACE_FRICTION)

	ANIM.set_flip_h(1-xDirection)
	particleJetDown.position = Vector2(-6*xDirection, -2*yDirection)
	particleJetUp.position = Vector2(-6*xDirection, -2*yDirection)

func applyPlanetMovement(delta):
	var flr = is_on_floor()
	
	if(ANIM.frame ==6):
		ANIM.frame = 1
	if(Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")):
		ANIM.frame = 0
	if(Input.is_action_pressed("ui_left")):
		xDirection = -1
		speed.x += ACCELERATION * xDirection
		if(flr):
			ANIM.play("Run")
	elif(Input.is_action_pressed("ui_right")):
		xDirection = 1
		speed.x += ACCELERATION * xDirection
		if(flr):
			ANIM.play("Run")
	else:
		speed.x = lerp(speed.x, 0, FRICTION)
		if(flr):
			ANIM.play("Idle")
			speed.y = lerp(speed.y, 0, FRICTION)
	ANIM.set_flip_h(1-xDirection)
	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)

func applyPlanetJump(delta):
	var flr = is_on_floor()
	if(flr):
		if(Input.is_action_pressed("ui_up")):
			speed.y = -JUMP_SPEED 
		else:
			speed.y += JUMP_SPEED * delta	
	speed.y = clamp(speed.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
	#Animation
	if(speed.y < 0):
		ANIM.play("Jump")
	elif(!flr):
		ANIM.play("Fall")
		
	
func applyPlanetGravity(delta):
	if(closestPlanet != null):
		var pos = get_global_position()
		if(closestPlanet.is_in_gravity_field(pos) and !is_on_floor()):
			speed.y += closestPlanet.gravityForce / (pos.distance_to(closestPlanet.get_global_position())-closestPlanet.radius)

func get_gravity_vector(planet):
	return (planet.gravityCentre.get_global_position()-get_global_position()).normalized()
	
func get_closest_planet():
	var distance = -1
	var foundPlanet = null
	
	for planet in get_tree().get_nodes_in_group("Planet"):
		if(planet.gravityCentre):
			if(distance < 0):
				foundPlanet = planet
				distance = planet.gravityCentre.get_global_position().distance_to(get_global_position())
			elif(distance > planet.gravityCentre.get_global_position().distance_to(get_global_position())):
				foundPlanet = planet
				distance = planet.gravityCentre.get_global_position().distance_to(get_global_position())
				
	return foundPlanet


