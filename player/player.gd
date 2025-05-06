extends TankController
class_name Player

var id : int

func _process(delta):
	update_movement_input()
	
	if Input.is_action_pressed("DEBUG_QUIT") : get_tree().quit() #DEBUG
	

func update_movement_input() :
	var input : Vector2
	input.x = Input.get_axis("player" + str(id) + "_left", "player" + str(id) + "_right")
	input.y = Input.get_axis("player" + str(id) + "_down", "player" + str(id) + "_up")
	set_tank_input(input)
