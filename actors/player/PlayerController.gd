extends KinematicBody2D

class_name Player

# Ground Physics Constants
const GROUND_MOVE_FORCE = 600
const GROUND_MAX_SPEED = 300

# Air Physics Constants
const AIR_MOVE_FORCE = 400
const AIR_MAX_SPEED = 300
onready var gravity = 200

const MAX_AIR_JUMPS = 2
var air_jumps = MAX_AIR_JUMPS

# General Physics Constants
const STOP_FORCE = 1300
const JUMP_SPEED = 200

var velocity = Vector2()

# player gamestate stuff
enum STATES {GROUND, AIR, GROUND_LIGHT, GROUND_HEAVY, AIR_LIGHT, AIR_HEAVY}

var player_state

var facing_right : bool

var light_attack_amt : int = 0

var attacks

# debug ui information
var debug_label : Label

func _ready():
	player_state = STATES.GROUND
	facing_right = true
	
	# initialize hitboxes
	attacks = get_node("MeleeAttacks").get_children()
	
	for attack in attacks:
		if attack is AttackData:
			attack.player = self

func handle_movement(delta: float):
	# set variables based on states
	
	var move_force : float = 0
	var max_speed : float = 0
	
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
		var currDirection = walk > 0
		if (facing_right != currDirection):
			apply_scale(Vector2(-1.0, 1.0))
			move_local_x(-44.5 * 2)
			facing_right = currDirection
		#print(facing_right)
	
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func attempt_jump():
	if Input.is_action_just_pressed("jump"):
		if player_state == STATES.GROUND:
			velocity.y = -JUMP_SPEED
		elif air_jumps > 0:
			velocity.y = -JUMP_SPEED
			air_jumps -= 1
		

func set_states():
	# is_on_floor() must be called after movement code.
	if is_on_floor():
		player_state = STATES.GROUND
		# refill air jumps
		air_jumps = MAX_AIR_JUMPS
	else:
		player_state = STATES.AIR

func do_attacks():
	# enable hitbox if its disabled, else dont
	if !$AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("light_attack"):
			$AnimationPlayer.play("punch")
		if Input.is_action_just_pressed("heavy_attack"):
			if player_state == STATES.AIR:
				$AnimationPlayer.play("light_launcher")
			else:
				$AnimationPlayer.play("down_spike")
		

func _physics_process(delta: float):
	handle_movement(delta)
	attempt_jump()
	set_states()
	do_attacks()
	 
