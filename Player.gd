extends KinematicBody2D


var speed = Vector2.ZERO
var direction = 0
var velocity = Vector2()
var closestPlanet = null
var playerRot = 0


const MAX_SPEED = 2000
const MAX_VERTICAL_SPEED = 10000
const JUMP_SPEED = 10000
const ACCELERATION = 50
const FRICTION = 0.1

onready var child_sprite = $AnimatedSprite

enum {
	LEFT = -1,
	RIGHT = 1,
	IDLE = 0
}

func _ready():
	set_physics_process(true)
	closestPlanet = null

func _physics_process(delta):
	
	var nextPlanet = get_closest_planet()
	
	#If changing planet
	if(nextPlanet != closestPlanet && nextPlanet.is_in_gravity_field(get_global_position())):
		closestPlanet = nextPlanet
		
		#invert y velocity
		speed.y = -speed.y
	
	applyMovement(delta)
	applyGravity(delta)
	applyJump(delta)
	

	if(closestPlanet):
		var planetT = closestPlanet.gravityCentre.get_global_position()
		var targetDir = get_global_position() - planetT
		var smoothForce = 500
		var smooth = smoothForce/(get_global_position().distance_to(closestPlanet.get_global_position()))

		#direction = targetDir.normalized()
		var facing = atan2(targetDir.x, -targetDir.y)
		playerRot = lerp_angle(playerRot, facing, smooth * delta)

	velocity = Vector2(speed.x * delta, speed.y * delta)
	velocity = velocity.rotated(playerRot)

	var up_direction = Vector2(sin(playerRot), -cos(playerRot))
	velocity = move_and_slide(velocity, up_direction)
	
	set_rotation(playerRot)
	
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func applyMovement(delta):
	if(Input.is_action_pressed("ui_left")):
		direction = -1
		speed.x += ACCELERATION * direction
	elif(Input.is_action_pressed("ui_right")):
		direction = 1
		speed.x += ACCELERATION * direction
	else:
		speed.x = lerp(speed.x, 0, FRICTION)
		
	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)

func applyJump(delta):
	if(is_on_floor()):
		if(Input.is_action_pressed("ui_up")):
			speed.y = -JUMP_SPEED
		else:
			speed.y += JUMP_SPEED * delta
				
	speed.y = clamp(speed.y, -JUMP_SPEED, JUMP_SPEED)

func applyGravity(delta):
	if(closestPlanet != null):
		var pos = get_global_position()
		if(closestPlanet.is_in_gravity_field(pos)):
			speed.y += closestPlanet.gravityForce / (pos.distance_to(closestPlanet.get_global_position())-closestPlanet.radius)

func get_player_rotation():
	var downVector = Vector2(0,1)
	if(closestPlanet):
		var t = get_transform()
		var lookDir = closestPlanet.get_transform().origin - t.origin()
		var rotTransform = t.looking_at(lookDir, Vector3(0,1,0))
		return get_gravity_vector(closestPlanet)
	else:
		var t = get_transform()
		return t.looking_at(t.origin(), Vector3(0,1,0))
	
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
