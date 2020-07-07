extends Camera2D

const TurnTowards = preload("res://turn_towards.gd")
const distToEdges = 1000

onready var topleft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight
onready var player = get_tree().get_nodes_in_group("Player")
onready var viewport = get_viewport_transform()
onready var turn_towards = TurnTowards.new()

var maxRotateSpeed = 0.03
var rotateSpeed = 0.00
var switch = false
var rot = 0

func _ready():
	limit_top = topleft.position.y
	limit_left = topleft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
	
func _physics_process(delta):
	set_global_position(player[0].get_global_position())
	rot = turn_towards.rot_towards(rot, player[0].get_rotation(), delta)
	set_rotation(rot)
	#LEFT
	if(position.x-limit_left < distToEdges):
		set_zoom(Vector2(0.2 + (distToEdges/(position.x-limit_left))-1, 0.2 + (distToEdges/(position.x-limit_left))-1))
	#RIGHT
	if(limit_right-position.x < distToEdges):
		set_zoom(Vector2(0.2 + (distToEdges/(limit_right-position.x))-1, 0.2 + (distToEdges/(limit_right-position.x))-1))
	#TOP
	if(position.y-limit_top < distToEdges):
		set_zoom(Vector2(0.2 + (distToEdges/(position.y-limit_top))-1, 0.2 + (distToEdges/(position.y-limit_top))-1))
	#BOTTOM
	if(limit_bottom-position.y < distToEdges):
		set_zoom(Vector2(0.2 + (distToEdges/(limit_bottom-position.y))-1, 0.2 + (distToEdges/(limit_bottom-position.y))-1))
