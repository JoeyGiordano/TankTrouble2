extends RigidBody2D
class_name MultiBullet

@onready var hitbox : Area2D = $Hitbox

# Concept: on collision, remove multi bullet isntance and replace with 6 to 7 regular bullet spraying outward

var source_tank_id : int = -1
var source_tank_invincible : bool = true #this will get turned off 0.1 seconds after the bullet is shot, prevents tanks from accidentally shooting themselves unless they are going way faster than their own bullets
var dir_changed : bool = false #set to true the first time the bullet bounces

var speed : float
var dir : Vector2
var lifetime : float #lifetime in seconds

#region - variables for the spawned shards
var shard_speed: float = 200.0
var shard_lifetime: float = 1.5
var disable_collision_on_explode: bool = true
var exploded: bool = false
var spawn_radius: float = 0.0
var shards : Array[BasicBullet] = []
#endregion


func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)
	hitbox.area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)
	
	linear_velocity = speed * dir.normalized()
	
	#source tank invincibility
	await get_tree().create_timer(0.07).timeout
	source_tank_invincible = false

func _process(delta):
	lifetime -= delta
	#if the multibullet has met lifespan and has not spawned shards, then queue free
	if lifetime <= 0 and shards.size() == 0 :
		#play bullet disappread sound and anim
		queue_free()

## Signal Response

func on_area_entered(area : Area2D) : #contact_monitor must be set to true and max_contacts_reported must be >0
	# explode once
	if exploded:
		return
	exploded = true
	
	#if is_instance_valid(hitbox):
		#disable player collision until timer
		#hitbox.set_deferred("monitoring", false)
		#hitbox.set_deferred("monitorable", false)
		#hitbox.get_child(0).set_deferred("disabled", true) # double check to make sure polgon 2d is 
		#print("Multibullet collision disabled")
			
	# handle hitting player
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		if tank.id == source_tank_id && source_tank_invincible :
			return #a tank can't hit itself with its own bullet for a brief moment after the bullet has been shot
		tank.die()
		#queue_free()
		spawn_shards()


func on_body_entered(_body : Node) :
	if exploded:
		return
	exploded = true
	
	# dir_changed = true
	#added vvvv
	spawn_shards()
	#var b : BasicBullet = Ref.basic_bullet.instantiate()
	
func on_end_of_round() :
	queue_free()

## Misc
func spawn_shards() -> void: #Array[BasicBullet]:
	var base_dir :  Vector2;
	# make sure direction is not 0, not sure if I even have to handle this
		
	# four directions (degrees) --> (0, 90, 180, 270)
	var angles := [0, 0.5 * PI, PI, 1.5 * PI]
	for a in angles:
		# get direcion
		var bb : BasicBullet = BasicBullet.instantiate(global_position, speed, dir, shard_lifetime)
		bb.source_tank_id = source_tank_id   # preserve ownership 
		shards.append(bb)	#add to shards array referece

	return

func despawn_shards():
	return

static func instantiate(position_ : Vector2 , speed_ : float, dir_ : Vector2, lifetime_ : float) -> MultiBullet :
	#create a new bullet and return it
	#instantiate a tank from the .tscn
	#need to add to ref file
	var b : MultiBullet = Ref.multi_bullet.instantiate() #have to call to game container here bc this method is static
	#set the variables
	b.speed = speed_
	b.dir = dir_
	b.position = position_
	b.lifetime = lifetime_
	
	#add the new bullet to the scene tree in the correct placem
	Global.Entities.add_child(b)
	return b
