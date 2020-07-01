extends RigidBody2D

export var effectRadius = 100
export var radius = 16
export var gravityForce = 100
export var orbitRadius = 100
export var orbitSpeed = 5
export var orbitTime = 10
export var orbitDirection = 1

onready var gravityCentre = $GravityCentre
onready var atmos = $Atmosphere
onready var originalPosition = transform.origin

var velocity = Vector2.ZERO
var rot = 0
var angularSpeed = 0


func _ready():
	atmos.set_gravity_is_point(true)
	atmos.get_node("GravityEffect").get_shape().set_radius(effectRadius)
	get_node("Radius").get_shape().set_radius(radius)
	set_mode(MODE_KINEMATIC)
	#set_position(Vector2(orbitRadius,0))

func _physics_process(delta):
	#If this planet orbits anything
	if(orbitRadius):
		rot += delta
		var v = (2*PI*orbitRadius) / orbitTime
		velocity = Vector2(v * sin(rot), v * cos(rot))

		transform.origin = originalPosition + velocity
	#var gravityCentre = $GravityCentre
	

func is_in_gravity_field(pos):
	return gravityCentre.get_global_position().distance_to(pos) <= effectRadius

