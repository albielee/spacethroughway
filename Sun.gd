extends Node2D


const colors = [Color("2b0f54"),Color("ab1f65"),Color("ff4f69"),Color("fff7f8"),Color("ff8142"),
				Color("ffda45"),Color("3368dc"),Color("49e7ec")]
const scl = 2.5
const wiggleRoom = 10
const sunSpeed = 5

func _ready():
	var lights = get_children()
	var c = 0
	var n = 0
	for light in lights:
		c += 1
		n+=1
		if(n>7):
			n=0
		
		var s = rand_range(0,1.5)+scl
		light.set_texture_scale(s)
		light.set_color(colors[rand_range(0,8)])
		light.set_energy(3/s)
		light.rotation_degrees = c*10
		light.set_shadow_gradient_length(1.5)
		light.set_shadow_smooth(0.1)

func _process(delta):
	var lights = get_children()
	var c = 0
	var alternateDir = 1
	for light in lights:
		c+=1
		alternateDir *= -1
		light.rotation_degrees += delta*alternateDir * (c/sunSpeed) #+ rand_range(-wiggleRoom,wiggleRoom)
	#rotation_degrees += delta
