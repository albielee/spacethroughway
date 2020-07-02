extends RigidBody2D

export var gravityForce = 100
export var orbitRadius = 100
export var orbitTime = 10
export var orbitDirection = 1
export var planetType = 0

onready var gravityCentre = $GravityCentre
onready var atmos = $Atmosphere
onready var originalPosition = transform.origin
onready var collisionRadius = get_node("Radius").duplicate()

var velocity = Vector2.ZERO
var rot = 0
var angularSpeed = 0
var radius = 0
var effectRadius = 64


func _ready():
	atmos.set_gravity_is_point(true)
	
	var changeType = 0
	if(planetType <= 3):	
		$Back.set_animation("Small")
		$Front.set_animation("Small")
		radius = 15
		effectRadius = radius*2.5
	if(planetType > 3 && planetType <= 8):	
		$Back.set_animation("Medium")
		$Front.set_animation("Medium")

		radius = 30
		effectRadius = radius*2.5
		changeType = 4
	
	collisionRadius.get_shape().set_radius(radius)
	set_mode(MODE_KINEMATIC)
	atmos.get_node("GravityEffect").get_shape().set_radius(effectRadius)
	#Set planet sprite
	$Back.frame = planetType-changeType
	$Front.frame = planetType-changeType
	#Set sprite depths
	$Front.z_index = 1000

func _physics_process(delta):
	#If this planet orbits anything
	if(orbitRadius):
		rot += (delta*60) / orbitTime
		var v = (2*PI*orbitRadius) / orbitTime
		velocity = Vector2(v * sin(rot), v * cos(rot))

		transform.origin = originalPosition + velocity
	#var gravityCentre = $GravityCentre
	

func is_in_gravity_field(pos):
	return gravityCentre.get_global_position().distance_to(pos) <= effectRadius

