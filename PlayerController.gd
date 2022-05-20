extends KinematicBody2D

class_name Player

# Ground Physics Constants
const GROUND_MOVE_FORCE = 600
const GROUND_MAX_SPEED = 300

# Air Physics Constants
const AIR_MOVE_FORCE = 400
const AIR_MAX_SPEED = 300
onready var gravity = 200

# General Physics Constants
const STOP_FORCE = 1300
const JUMP_SPEED = 200

var velocity = Vector2()

# player gamestate stuff
enum STATES {GROUND, AIR}

var player_state

var facing_right : bool

func _ready():
	player_state = STATES.GROUND
	facing_right = true
	
	var hitbox = $AttackHitbox/Area2D
	hitbox.connect("body_entered", self, "on_hitbox_entered")

func handle_movement(delta: float):
	# set variables based on states
	
	var move_force : float
	var max_speed : float
	
	match player_state:
		STATES.GROUND:
			move_force = GROUND_MOVE_FORCE
			max_speed = GROUND_MAX_SPEED
		STATES.AIR:
			move_force = AIR_MOVE_FORCE
			max_speed = AIR_MAX_SPEED
	
	# Horizontal movement code. First, get the player's input.
	var walk = move_force * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < move_force * 0.2:
		# this is below deadzone
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
		# set facing direction here since we accounted for dead zone
		facing_right = walk > 0
		#print(facing_right)
	
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func attempt_jump():
	if player_state == STATES.GROUND and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED

func set_states():
	# is_on_floor() must be called after movement code.
	if is_on_floor():
		player_state = STATES.GROUND
	else:
		player_state = STATES.AIR

func do_attacks():
	# enable hitbox if its disabled, else dont
	if Input.is_action_pressed("attack"):
		$AttackHitbox.visible = true
		$AttackHitbox/Area2D/CollisionShape2D.disabled = false
		
		var current_position_x = $AttackHitbox/Area2D.position.x
	
		# flip hitbox only if facing the correct direction and the transform hasnt flipped yet
		if facing_right and current_position_x < 0:
			$AttackHitbox/Area2D.position.x = -$AttackHitbox/Area2D.position.x
		elif !facing_right and current_position_x > 0:
			$AttackHitbox/Area2D.position.x = -$AttackHitbox/Area2D.position.x
		
	else:
		$AttackHitbox.visible = false
		$AttackHitbox/Area2D/CollisionShape2D.disabled = true
	

func on_hitbox_entered(body):
	#print("does this work")
	if body.is_in_group("enemies"):
		print("Yay")

func _physics_process(delta: float):
	
	handle_movement(delta)
	attempt_jump()
	set_states()
	do_attacks()
	#print("right: " + str(Input.is_action_pressed("move_right")))
