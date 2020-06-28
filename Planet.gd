extends StaticBody2D

export var effectRadius = 100
export var radius = 10
export var gravityForce = 10000

onready var gravityCentre = $GravityCentre
onready var atmos = $Atmosphere

func _ready():
	atmos.set_gravity_is_point(true)
	atmos.get_node("GravityEffect").get_shape().set_radius(effectRadius)
	get_node("Radius").get_shape().set_radius(radius)

func _physics_process(delta):
	var gravityCentre = $GravityCentre

func is_in_gravity_field(pos):
	return gravityCentre.get_global_position().distance_to(pos) <= effectRadius

