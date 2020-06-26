extends KinematicBody2D

var motion = Vector2()
var speed = 100

const MAX_VERTICAL_SPEED = 100

func _physics_process(delta):
	
	motion.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	
	#Jumping
	if(is_on_floor()):
		if(Input.is_action_just_pressed("ui_up")):
			motion.y = -100
	
	#Gravity
	motion.y += 2
	motion.y = clamp(motion.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
	
	move_and_slide(motion*speed, Vector2.UP)
	pass
