extends RigidBody2D


var rot = 0
var speed = Vector2.ZERO
var velocity = Vector2()
var closestPlanet = null
var inSpace = true

const TurnTowards = preload("res://turn_towards.gd")

onready var turn_towards = TurnTowards.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_linear_damp(0.5)


func _physics_process(delta):
	inSpace = true
	var nextPlanet = get_closest_planet()
	#Switch area state
	if(nextPlanet.is_in_gravity_field(get_global_position())):
		inSpace = false
		#If changing planet
		if(nextPlanet != closestPlanet):
			closestPlanet = nextPlanet
	var maxV = 50
	if(!inSpace):
		applyPlanetGravity(delta)
		velocity = Vector2(speed.x * delta, speed.y * delta)
		velocity.x = clamp(velocity.x, -maxV, maxV)
		velocity.y = clamp(velocity.y, -maxV, maxV)
		velocity = velocity.rotated(rot)
		#Rotate player towards planet
		if(closestPlanet):
			var planetT = closestPlanet.gravityCentre.get_global_position()
			var smoothForce = 500
			var smooth = smoothForce/(get_global_position().distance_to(closestPlanet.get_global_position()))
			rot = turn_towards.turn_towards(rot, get_global_position(), planetT, smooth * delta)
		else:
			rot = get_rotation()
		
		#Set rotation
		set_rotation(rot)
	else:
		velocity = Vector2.ZERO
	#Set rotation and rotation of velocity vector
	var vx = get_linear_velocity().x
	var vy = get_linear_velocity().y
	if(abs(vx) > maxV):
		set_linear_velocity(Vector2(sign(vx)*maxV,vy))
	if(abs(vy) > maxV):
		set_linear_velocity(Vector2(vx,sign(vy)*maxV))
	
	set_applied_force(velocity)
	

func applyPlanetGravity(delta):
	if(closestPlanet != null):
		var pos = get_global_position()
		if(closestPlanet.is_in_gravity_field(pos)):
			speed.y += closestPlanet.gravityForce / (pos.distance_to(closestPlanet.get_global_position())-closestPlanet.radius)

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
