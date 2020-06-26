extends KinematicBody2D

var motion = Vector2()
var gravity = 10#Var not const because changed by planets
var speed = 0
var direction = 0

const MAX_SPEED = 200
const MAX_VERTICAL_SPEED = 300
const JUMP_SPEED = 300
const ACCELERATION = 20
const FRICTION = 0.1

onready var child_sprite = $AnimatedSprite

enum {
	LEFT = -1,
	RIGHT = 1,
	IDLE = 0
}

func _physics_process(delta):
	
	motion.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	var friction = false
	#Flip sprite on direction
	if(motion.x > 0):
		direction = RIGHT
		speed += ACCELERATION
		child_sprite.flip_h = false
		child_sprite.play("Run")
	elif(motion.x < 0):
		direction = LEFT
		speed += ACCELERATION
		child_sprite.flip_h = true
		child_sprite.play("Run")
	else:
		friction = true
		child_sprite.play("Idle")
		
	speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
	motion.x = direction*speed	

	#Jumping
	if(is_on_floor()):
		if(friction):
			speed = lerp(speed, 0, FRICTION)
		if(Input.is_action_just_pressed("ui_up")):
			motion.y = -JUMP_SPEED
	else:
		if(friction):
			speed = lerp(speed, 0, FRICTION/2)
		child_sprite.play("Jump")
	
	#Gravity
	motion.y += gravity
	motion.y = clamp(motion.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
	
	motion = move_and_slide(motion, Vector2.UP)

