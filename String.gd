extends Node2D

export (float) var length = 30
export (float) var constrain = 1
export (Vector2) var gravity = Vector2(0,9.8)
export (float) var friction = 0.9
export (bool) var start_pin = true
export (bool) var end_pin = true

var pos: PoolVector2Array
var pos_ex: PoolVector2Array
var lightLine: PoolVector2Array
var count: int
var initial_pos: Vector2
var n = 0

#Rope is created with energy dispencers
onready var energy_dispencer = get_parent()
onready var plug = energy_dispencer.get_node("Plug")
onready var dispencer = energy_dispencer.get_node("Dispencer")

func _ready():
	initial_pos = energy_dispencer.global_position
	count = get_count(length)
	resize_arrays()
	init_position()

func get_count(distance: float):
	var new_count = ceil(distance / constrain)
	return new_count

func resize_arrays():
	pos.resize(count)
	pos_ex.resize(count)
	lightLine.resize(count)

func init_position():
	global_position = initial_pos
	for i in range(count):
		pos[i] = global_position + Vector2(constrain *i, 0)
		pos_ex[i] = global_position + Vector2(constrain *i, 0)
		lightLine[i] = pos[i]
	position = Vector2.ZERO

func _process(delta):
	update_position(delta)
	update_points(delta)
	update_distance()

	$Line2D.points = pos
	$LightLine.points = pos
	#modulate the width of the light from line
	if(n < 2.5):
		n += 0.003
	else:
		n = 0.6
	$LightLine.width = sin(n)*6

func update_position(delta):
	#plug end
	pos[count-1] = plug.get_position()
	pos_ex[count-1] = plug.get_position()

	#dispencer end
	pos[0] = dispencer.get_position()
	pos_ex[0] = dispencer.get_position()

func update_points(delta):
	for i in range (count):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=count-1) || (i==0 && !start_pin) || (i==count-1 && !end_pin):
			var vec2 = (pos[i] - pos_ex[i]) * friction
			pos_ex[i] = pos[i]
			pos[i] += vec2 + (gravity * delta)

func update_distance():
	for i in range(count):
		if i == count-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		if i == 0:
			if start_pin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		elif i == count-1:
			pass
		else:
			if i+1 == count-1 && end_pin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
