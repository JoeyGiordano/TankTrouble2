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
		

## Loadout Management

func get_loadout() -> TankLoadout : 
	return get_child(0)

func replace_loadout(type : TankLoadout.Type) :
	#using call_deferred ensures that _replace_loadout is not called during a physics frame, loadouts are collsion objects and switching a rigidbody's collision object mid physics update can be bad
	print("hehrsssxxxx")
	call_deferred("_replace_loadout", type)

func _replace_loadout(type : TankLoadout.Type) :
	print("hehrsss")
	#destroy the old tank loadout
	get_child(0).queue_free()
	remove_child(get_child(0))
	#create a new tank loadout as a child of this node
	TankLoadout.instantiate(self, type)

## Resource

func teleport_to(new_global_position : Vector2) :
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		global_position = new_global_position
		freeze = false

# tank directions

func forward() -> Vector2 :
	return transform.x

func backward() -> Vector2 :
	return -transform.x

func left() -> Vector2 :
	return -transform.y

func right() -> Vector2 :
	return transform.y
