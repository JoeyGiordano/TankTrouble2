extends RigidBody2D
class_name TankRigidbody

## Script on the rigidbody.
## Manages movement and switching tank loadouts (which are collision objects).

var linear_stop_damp : float = 0.186
var angular_stop_damp : float = 4.27

@onready var tank : Tank = get_parent()

var locked : bool = false

func move_and_rotate() :
	#should only be called in _physics_process()
	#moves the tank forward or backwards based on y input, rotates the tank based on x input
	#does not use forces, just sets the linear_velocity and angular_velocity
	if locked :
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		return
	
	var move_input = tank.move_input
	#forwards-backwards movement
	if move_input.y > 0:
		linear_velocity = move_input.y * tank.stats.forward_speed * transform.x #scalar * scalar * vector (forward direction)
	elif move_input.y < 0:
		linear_velocity = move_input.y * tank.stats.backward_speed * transform.x
	else :
		#makes the linear velocity go to zero smoothly (the higher the speed stat, the faster the speed needs to drop)
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO,linear_stop_damp*max(abs(tank.stats.forward_speed),abs(tank.stats.backward_speed)))
	
	#rotation
	if move_input.x :
		angular_velocity = move_input.x * tank.stats.rotation_speed
	else :
		#makes the angular velocity go to zero smoothly (the higher the speed stat, the faster the speed needs to drop)
		angular_velocity = move_toward(angular_velocity, 0, angular_stop_damp*tank.stats.rotation_speed)

## Loadout Management

func get_loadout() -> TankLoadout : 
	return get_child(0)

func replace_loadout(type : TankLoadout.Type) :
	#using call_deferred ensures that _replace_loadout is not called during a physics frame, loadouts are collsion objects and switching a rigidbody's collision object mid physics update can be bad
	call_deferred("_replace_loadout", type)

func _replace_loadout(type : TankLoadout.Type) :
	#destroy the old tank loadout
	get_child(0).queue_free()
	remove_child(get_child(0))
	#create a new tank loadout as a child of this node
	TankLoadout.instantiate(self, type)

## Resource

func teleport_to(new_global_position: Vector2) :
	#using call_deferred (combined with await get_tree().physics_frame) ensures that _teleport_to
	#is not called during a physics frame, changing the physics state mid physics process can be bad
	#this is still a kind of a workaround so it might get weird behavior (make sure hidden tanks teleport actually teleport)
	#the fact that there is not support for manually moving rigidbodies in godot is... upsetting
	call_deferred("_deferred_teleport", new_global_position)

func _deferred_teleport(new_global_position: Vector2) :
	await get_tree().physics_frame
	global_position = new_global_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	sleeping = true
	set_deferred("sleeping", false)

func lock() :
	locked = true

func unlock() :
	locked = false

# tank directions

func forward() -> Vector2 :
	return transform.x

func backward() -> Vector2 :
	return -transform.x

func left() -> Vector2 :
	return -transform.y

func right() -> Vector2 :
	return transform.y
	
	
