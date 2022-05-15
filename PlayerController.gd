extends KinematicBody2D

const GROUND_MOVE_FORCE = 600
const GROUND_MAX_SPEED = 400
const STOP_FORCE = 1300
const JUMP_SPEED = 200

var velocity = Vector2()

onready var gravity = 200

enum STATES {GROUND, AIR}

var player_state

func _ready():
	player_state = STATES.GROUND

func _physics_process(delta):
	
	# set variables based on states
	
	var move_force : float
	var max_speed : float
	
	match player_state:
		STATES.GROUND:
			move_force = GROUND_MOVE_FORCE
			max_speed = GROUND_MAX_SPEED
		STATES.AIR:
			move_force = GROUND_MOVE_FORCE
			max_speed = GROUND_MAX_SPEED
	
	# Horizontal movement code. First, get the player's input.
	var walk = move_force * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < move_force * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# is_on_floor() must be called after movement code.
	if is_on_floor():
		player_state = STATES.AIR
	# Check for jumping.
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP_SPEED
	else:
		player_state = STATES.GROUND
	
	#print("right: " + str(Input.is_action_pressed("move_right")))
