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

export var pushback : Vector2

export var attack_type : String

signal hit_succesful(attack_type)

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
	
	#attack_type = "Null"


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
		if body.current_stun == 0:
			# reset the combo count back to one if enemy is no longer in stun
			player.combo_count = 1
		else:
			player.combo_count += 1
		
		print("Hit: ", player.combo_count, ", stun: ", body.current_stun)
		
		# calculate pushback
		#var pushback : Vector2
		if player.facing_right:
			pushback.x = abs(pushback.x)
		else:
			pushback.x = -abs(pushback.x)
		
		# calculate stun (attempt to do some staling)
		var stun : int = 30 - player.combo_count - 5
		
		body.add_combo_hit(1, stun, pushback)
		
		emit_signal("hit_succesful", attack_type)
