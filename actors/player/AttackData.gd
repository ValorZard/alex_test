extends Area2D

class_name AttackData

# the idea behind this script is that this should be used as a generic script for every single melee attack.
# special attacks should have their own dedicated script that may or may not inherit from this

# current attack states
# probably a better way to do this to make it more flexible, but I'll do it like this for now
# states depend if your on the ground or air
# var hit : array = []

#var current_attack_state = GROUND_STATES.HIT_1

# define this at runtime by the player who initalized all the attack scripts
var player

export var attack_type : String

export var damage : int = 1

export var hitstun : int = 1

export var pushback : Vector2

export var pushback_time : int = 1 # number of frames pushback lasts

#signal hit_succesful(attack_type)

# refactoring code to do callbacks to know if
# 1. what strenght the attack is to store in attack history for combo string
# 2. if the attack actually hit or not

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: find better way to do this that wont just instantly break on contact
	#player = get_parent().get_parent()
	#print(player.combo_count)
	# set up signal for hitbox
	self.connect("body_entered", self, "on_hitbox_entered")
	
	# make sure default hitbox is disabled
	$CollisionShape2D.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# handle flupping hitboxes depending on position
	var current_position_x = position.x
	# flip hitbox only if facing the correct direction and the transform hasnt flipped yet
	if player.facing_right and current_position_x < 0:
		position.x = -position.x
	elif !player.facing_right and current_position_x > 0:
		position.x = -position.x
	

func on_hitbox_entered(body):
	#print("does this work")
	if body.is_in_group("enemies"):
		# honestly, i think the player should handle counting the combo hits
		#if len(AttackManager.list_of_enemies_in_stun) == 0:
			# reset the combo count back to one if enemy is no longer in stun
		#	AttackManager.combo_count = 1
		#else:
		#	AttackManager.combo_count += 1
		
		# calculate pushback
		#var pushback : Vector2
		if player.facing_right:
			pushback.x = abs(pushback.x)
		else:
			pushback.x = -abs(pushback.x)
		
		# calculate stun (attempt to do some staling)
		#var stun : int = 30 - AttackManager.combo_count - 5
		#var stun : int = 25
		
		body.add_combo_hit(1, damage, hitstun, pushback, pushback_time)
		
