extends KinematicBody2D

class_name Enemy

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#var combo_hit_counter : int = 0
var current_stun : int = 0
var current_pushback : Vector2
var current_pushback_time : int = 0
export var health : int = 10

# check if enemy got hit so that we can add to the combo counter enemy list
var is_hit : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# make sure that this is part of Enemy group
	add_to_group("enemies")
	# set up progress bar
	$ProgressBar.max_value = health
	$ProgressBar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_on_floor():
		move_and_slide(Vector2(0, 100))
	# deal with stun/combos; drop combo if no long in stun
	if current_stun > 0:
		current_stun -= 1
		# change color to show if in hitstun
		self.modulate = Color(0, 0, 1)
	else:
		#combo_hit_counter = 0
		self.modulate = Color(1, 1, 1)
		is_hit = false
		if AttackManager.list_of_enemies_in_stun.has(self):
			AttackManager.list_of_enemies_in_stun.erase(self)
	# deal with pushback time (make sure it lasts the correct amount of frames
	if current_pushback_time > 0:
		current_pushback_time -= 1
		move_and_slide(current_pushback)
		

func add_combo_hit(hit : int, damage : int, stun : int, pushback : Vector2, pushback_time: int):
	if len(AttackManager.list_of_enemies_in_stun) == 0:
		# reset the combo count back to one if enemy is no longer in stun
		AttackManager.combo_count = 1
		# put it into the stun queue
		AttackManager.list_of_enemies_in_stun.push_back(self)
	else:
		AttackManager.combo_count += 1
	
	#combo_hit_counter += hit
	current_stun = stun
	current_pushback = pushback
	current_pushback_time = pushback_time
	health -= damage
	get_node("ProgressBar").value -= damage
	if health <= 0:
		on_death()

func on_death():
	# erase self from list CURRENTLY BUGGED
	if AttackManager.list_of_enemies_in_stun.has(self):
		AttackManager.list_of_enemies_in_stun.erase(self)
	self.queue_free()
