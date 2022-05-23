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
enum STATES {GROUND, AIR}

var player_state

var facing_right : bool

var combo_count : int = 0

func _ready():
	player_state = STATES.GROUND
	facing_right = true
	
	# initialize hitboxes
	var attacks := get_node("MeleeAttacks").get_children()
	
	for attack in attacks:
		if attack is AttackData:
			attack.player = self

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
		if Input.is_action_pressed("light_attack"):
			$AnimationPlayer.play("punch")
		else:
			pass
		
		# handle flupping hitboxes depending on position
		var current_position_x = $MeleeAttacks/LightAttack.position.x
		# flip hitbox only if facing the correct direction and the transform hasnt flipped yet
		if facing_right and current_position_x < 0:
			$MeleeAttacks/LightAttack.position.x = -$MeleeAttacks/LightAttack.position.x
		elif !facing_right and current_position_x > 0:
			$MeleeAttacks/LightAttack.position.x = -$MeleeAttacks/LightAttack.position.x

#func on_hitbox_entered(body):
#	#print("does this work")
#	if body.is_in_group("enemies"):
#		# honestly, i think the player should handle counting the combo hits
#		if body.current_stun == 0:
#			# reset the combo count back to one if enemy is no longer in stun
#			player_combo_count = 1
#		else:
#			player_combo_count += 1
#
#		print("Hit: ", player_combo_count, ", stun: ", body.current_stun)
#
#		# calculate pushback
#		var pushback : Vector2
#		if facing_right:
#			pushback = Vector2(200, -500)
#		else:
#			pushback = Vector2(-200, -500)
#
#		# calculate stun (attempt to do some staling)
#		var stun : int = 30 - player_combo_count - 5
#
#		body.add_combo_hit(1, stun, pushback)
#

func _physics_process(delta: float):
	
	handle_movement(delta)
	attempt_jump()
	set_states()
	do_attacks()
	#print("right: " + str(Input.is_action_pressed("move_right")))
