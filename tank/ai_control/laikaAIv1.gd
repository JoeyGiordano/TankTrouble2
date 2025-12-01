extends Tank
class_name LaikaAIv1 

@onready var ai_controller = $AIController2D
#tanks are designed to be easily controlled by code (see Tank script under ##INPUT for methods to call)
#all you have to do is add this node as a child of a tank (we might have to change this)

#right now he just goes in circles

func _physics_process(delta):
	if ai_controller == null:
		return

	set_move_input(Vector2(ai_controller.move_action.x,ai_controller.move_action.y))
	if ai_controller.shoot_action == 1:
		shoot()
func die():
	ai_controller.is_dead_flag = true
	super.die()
