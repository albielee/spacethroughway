extends KinematicBody2D

const MAX_SPEED = 100
const FRICTION = 50

enum STATE{
	IDLE = 0,
	CHASE = 1,
	WANDER = 2,
	ATTACK = 3,
	FLEE = 4
}

export var acceleration = 50
export var turnSpeed = 2
export var targetRadius = 200

var state = 0
var velocity = Vector2.ZERO

onready var turn_towards = preload("res://turnTowards.gd").new()
onready var wanderController = $WanderController
onready var playerDetection = $PlayerDetection
onready var detectionRange = $PlayerDetection/CollisionShape2D
onready var hurtBox = $Hurtbox
onready var particles = $Particles2D
onready var partBlue = preload("res://Sharks/SharkBlue.tres")
onready var partRed = preload("res://Sharks/SharkRed.tres")

func _ready():
	#set detection range
	detectionRange.get_shape().set_radius(targetRadius)

func _physics_process(delta):
	match state:
		STATE.WANDER:
			wander(delta)
		STATE.CHASE:
			chase(delta)
		STATE.FLEE:
			flee(delta)
		STATE.ATTACK:
			pass
	particles.set_speed_scale(velocity.length()/100)
	move_and_slide(velocity)
	
func rotate_shark(point, speed):
	set_rotation(turn_towards.turn_towards(get_rotation(), point, get_global_position(), speed))

func chase(delta):
	seek_player()
	var player = playerDetection.player
	
	if(player != null):
		if(player.state == 1):
			particles.set_process_material(partRed)
			
			#Rotate the shark towards the player
			rotate_shark(player.get_global_position(), turnSpeed * delta)
			velocity = velocity.move_toward(get_global_position().direction_to(player.get_global_position()) * MAX_SPEED, acceleration * delta)
		elif(player.state == 0):
			state = STATE.WANDER
	else:
		state = STATE.WANDER

func flee(delta):
	seek_player()
	var player = playerDetection.player
	if(player != null && player.state == 0):
		rotate_shark(-player.get_global_position(), turnSpeed * delta)
		velocity = velocity.move_toward(get_global_position().direction_to(player.get_global_position()) * -MAX_SPEED, acceleration * 4 * delta)
	else:
		state = STATE.WANDER
		
func wander(delta):
	particles.set_process_material(partBlue)
	
	seek_player()
	if(wanderController.get_time_left() == 0):
		update_wander()
	
	var targetPos = wanderController.target_position
	rotate_shark(targetPos, turnSpeed * delta)
	velocity = velocity.move_toward(get_global_position().direction_to(targetPos) * MAX_SPEED, acceleration * delta)
	#if near wander point, update wander
	if(global_position.distance_to(targetPos) <= MAX_SPEED * delta):
		update_wander()

func seek_player():
	if(playerDetection.can_see_player()):
		state = STATE.CHASE;

func update_wander():
	state = pick_random_state([STATE.WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
