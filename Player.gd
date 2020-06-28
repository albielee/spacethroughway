extends KinematicBody2D

var speed = Vector2.ZERO
var direction = 0
var velocity = Vector2()
var closestPlanet = null
var playerRot = 0
var state = 0 #0 = on planet gravity
var stateDelay = 0

const MAX_SPEED = 2000
const MAX_VERTICAL_SPEED = 10000
const JUMP_SPEED = 10000
const ACCELERATION = 50
const FRICTION = 0.1
const SPACE_FRICTION = 0.02

onready var child_sprite = $AnimatedSprite

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
			speed.y = -speed.y
	elif(stateDelay == 0):
		state = SPACE

	#State delay allows for the certainty of a state changed. This stops the player jumping
	#between space and planet states at the edge of a planets atmosphere
	if(stateDelay > 0):
		stateDelay -= 1
	
	match(state):
		PLANET:
			planetState(delta)
		SPACE:
			spaceState(delta)

	#Set rotation and rotation of velocity vector
	velocity = Vector2(speed.x * delta, speed.y * delta)
	velocity = velocity.rotated(playerRot)
	
	#Set player rotation
	set_rotation(playerRot)

	#Get up direction so that the floor can be determined based on rotation
	var up_direction = Vector2(sin(playerRot), -cos(playerRot))
	velocity = move_and_slide(velocity, up_direction)

func planetState(delta):
	applyPlanetMovement(delta)
	applyPlanetGravity(delta)
	applyPlanetJump(delta)

	#Rotate player towards planet
	if(closestPlanet):
		var planetT = closestPlanet.gravityCentre.get_global_position()
		var targetDir = get_global_position() - planetT
		var smoothForce = 500
		var smooth = smoothForce/(get_global_position().distance_to(closestPlanet.get_global_position()))

		var facing = atan2(targetDir.x, -targetDir.y)
		playerRot = lerp_angle(playerRot, facing, smooth * delta)
	else:
		playerRot = get_rotation()

func spaceState(delta):
	applySpaceMovement(delta)

func applySpaceMovement(delta):
	var xdir = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	var ydir = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	if(xdir or ydir):
		speed.x += ACCELERATION * xdir
		speed.y += ACCELERATION * ydir
	else:
		speed.x = lerp(speed.x, 0, SPACE_FRICTION)
		speed.y = lerp(speed.y, 0, SPACE_FRICTION)

func applyPlanetMovement(delta):
	if(Input.is_action_pressed("ui_left")):
		direction = -1
		speed.x += ACCELERATION * direction
	elif(Input.is_action_pressed("ui_right")):
		direction = 1
		speed.x += ACCELERATION * direction
	else:
		speed.x = lerp(speed.x, 0, FRICTION)
		
	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)

func applyPlanetJump(delta):
	if(is_on_floor()):
		if(Input.is_action_pressed("ui_up")):
			speed.y = -JUMP_SPEED
		else:
			speed.y += JUMP_SPEED * delta
				
	speed.y = clamp(speed.y, -JUMP_SPEED, JUMP_SPEED)

func applyPlanetGravity(delta):
	if(closestPlanet != null):
		var pos = get_global_position()
		if(closestPlanet.is_in_gravity_field(pos)):
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

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
