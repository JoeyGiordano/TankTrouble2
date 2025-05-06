extends RigidBody2D
class_name TankRigidbody

@export var forward_speed = 150.0
@export var backward_speed = 100.0
@export var rotation_speed = 4.0

var move_input : Vector2 = Vector2.ZERO
var shoot_input : bool = false

func _physics_process(delta):
	#move_input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_down", "ui_up"))
	move_and_rotate()

func move_and_rotate() :
	#should only be called in _physics_process()
	#moves the tank forward or backwards based on y input, rotates the tank based on x input
	#does not use forces, just sets the linear_velocity and angular_velocity
	
	#forwards-backwards movement
	if move_input.y > 0:
		linear_velocity = move_input.y * forward_speed * transform.x
	elif move_input.y < 0:
		linear_velocity = move_input.y * backward_speed * transform.x
	else :
		linear_velocity = Vector2.ZERO
	
	#rotation	
	if move_input.x :
		angular_velocity = move_input.x * rotation_speed
	else :
		angular_velocity = 0

func set_move_input(new_input : Vector2) :
	move_input = new_input

func set_shoot_input(new_input : bool) :
	shoot_input = new_input
