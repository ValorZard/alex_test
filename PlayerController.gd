extends KinematicBody2D

const MOVE_FORCE = 600
const GROUND_MAX_SPEED = 400
const STOP_FORCE = 1300
const JUMP_SPEED = 200

var velocity = Vector2()

onready var gravity = 200

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = MOVE_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < MOVE_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -GROUND_MAX_SPEED, GROUND_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
	
	#print("right: " + str(Input.is_action_pressed("move_right")))
