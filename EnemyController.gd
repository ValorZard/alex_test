extends KinematicBody2D

class_name Enemy

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var combo_hit_counter : int = 0
var current_stun : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# make sure that this is part of Enemy group
	add_to_group("enemies")
	pass # Replace with function body.


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
		combo_hit_counter = 0
		self.modulate = Color(1, 1, 1)

func add_combo_hit(hit : int, stun : int, pushback : Vector2):
	combo_hit_counter += hit
	current_stun = stun
	move_and_slide(pushback)
