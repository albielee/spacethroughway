extends Node2D

var planet

onready var player = get_node("res://Player.tscn")
onready var plug = $Plug

func _ready():
	planet = get_closest_planet()

func _process(delta):
	#update positions
	set_position(planet.position + Vector2(0,planet.radius))
	
	#plug.position = player.position

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
