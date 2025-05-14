extends RigidBody2D
class_name TankRigidbody

@export var forward_speed = 150.0
@export var backward_speed = 100.0
@export var rotation_speed = 4.0

@onready var tank : Tank = get_parent()

func move_and_rotate() :
	#should only be called in _physics_process()
	#moves the tank forward or backwards based on y input, rotates the tank based on x input
	#does not use forces, just sets the linear_velocity and angular_velocity
	var move_input = tank.move_input
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
