extends Node2D

onready var plug = $Plug

var planet = null
var player = null
var targetDis = null
var foundTargetDis = null
var dispencerValue = null

func _ready():
	z_index = 10

func _process(delta):
	if(planet != null):
		#update positions
		set_global_position(planet.position + Vector2(0,planet.radius+5))
		#set strings gravity
		$String.gravity = (planet.global_position-global_position).normalized()*10
	
	if(foundTargetDis != null):
		plug.global_position = foundTargetDis.global_position
	elif(player != null):
		plug.global_position = player.position
	#If plug in the right dispencer:
	var bodies = plug.get_overlapping_areas()
	if(bodies.size() > 1):
		for bod in bodies:
			if(bod.is_in_group("Dispencer") and bod != self):
				if(bod.dispencerValue == targetDis):
					player = null
					foundTargetDis = bod

func _on_Plug_body_entered(body):
	if(body.name == "Player"):
		player = body
