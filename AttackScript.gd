extends Area2D

class_name AttackData

# the idea behind this script is that this should be used as a generic script for every single melee attack.
# special attacks should have their own dedicated script that may or may not inherit from this

# current attack states
# probably a better way to do this to make it more flexible, but I'll do it like this for now
# states depend if your on the ground or air
var GROUND_STATES = {"HIT_1" : "GROUND_HIT_1", "HIT_2" : "GROUND_HIT_2", 
	"HIT_3" : "GROUND_HIT_3", "LAUNCHER" : "LAUNCHER"}

var AIR_STATES = {"HIT_1" : "AIR_HIT_1", "HIT_2" : "AIR_HIT_2", 
	"HIT_3" : "AIR_HIT_3", "SPIKE" : "SPIKE"}

var current_attack_state = GROUND_STATES.HIT_1

# define this at runtime by the player who initalized all the attack scripts
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: find better way to do this that wont just instantly break on contact
	#player = get_parent().get_parent()
	#print(player.combo_count)
	# set up signal for hitbox
	self.connect("body_entered", self, "on_hitbox_entered")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

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
		
		# the following stuff depends on the current state of the attack
		# first hit of combo, second hit and so on
		
		# attack change if in air or ground
		# currently broken, will always reset back to first hit regardless of if on the ground or not
		if player.is_on_floor():
			current_attack_state = GROUND_STATES["HIT_1"]
			print("first")
		
		if !player.is_on_floor():
			current_attack_state = AIR_STATES["HIT_1"]
			print("wait did i reach this")
		
		
		if current_attack_state == GROUND_STATES["HIT_1"]:
			# calculate pushback
			var pushback : Vector2
			if player.facing_right:
				pushback = Vector2(200, -5000)
			else:
				pushback = Vector2(-200, -5000)
		
			# calculate stun (attempt to do some staling)
			var stun : int = 30 - player.combo_count - 5
		
			body.add_combo_hit(1, stun, pushback)
		
		if current_attack_state == AIR_STATES["HIT_1"]:
			# calculate pushback
			var pushback : Vector2
			if player.facing_right:
				pushback = Vector2(200, -2000)
			else:
				pushback = Vector2(-200, -2000)
		
			# calculate stun (attempt to do some staling)
			var stun : int = 30 - player.combo_count - 5
		
			body.add_combo_hit(1, stun, pushback)
			
			#current_attack_state = AIR_STATES["HIT_2"]
		
		print(current_attack_state)
