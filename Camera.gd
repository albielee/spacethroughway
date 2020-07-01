extends Camera2D

const TurnTowards = preload("res://turn_towards.gd")

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
	#viewport.rotated(player[0].rotation)
	#set_global_transform(Transform2D(player[0].rotation, player[0].get_global_position()))
	#print(player[0].rotation)
	set_global_position(player[0].get_global_position())
	rot = turn_towards.rot_towards(rot, player[0].get_rotation(), delta)
	#rotation = lerp(rotation, player[0].rotation, maxRotateSpeed)
	#print(rot)
	print(get_global_position()-player[0].get_global_position())
	set_rotation(rot)
	#rotate(player[0].rotation)
