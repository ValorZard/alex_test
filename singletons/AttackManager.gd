extends Node


# Currently, this class only deals with handling the combo counter, and making it all accurate

var combo_count : int = 0
var list_of_enemies_in_stun : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass


func add_stunned_enemy(enemy : Enemy):
	if len(list_of_enemies_in_stun) == 0:
		# reset the combo count back to one if enemy is no longer in stun
		combo_count = 1
		# put it into the stun queue
		list_of_enemies_in_stun.push_back(enemy)
	else:
		combo_count += 1


func remove_enemy(enemy : Enemy):
	if list_of_enemies_in_stun.has(enemy):
		list_of_enemies_in_stun.erase(enemy)
	
