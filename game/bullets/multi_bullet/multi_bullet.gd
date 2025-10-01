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
var num_shards : int = 8
var shard_speed : float = 100.0
var shard_lifetime : float = 1.5
var exploded : bool = false
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
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		if tank.id == source_tank_id && source_tank_invincible :
			return #a tank can't hit itself with its own bullet for a brief moment after the bullet has been shot
		tank.die()
		#wait for tank to despawn so that bullet shards dont hit player
		await get_tree().create_timer(0.02).timeout
		spawn_shards()
		queue_free()

# when bullet hits a wall, it deletes itself and sprays the basic bullets
func on_body_entered(_body : Node) :
	spawn_shards()
	queue_free()
	
func on_end_of_round() :
	print("endround")
	despawn_shards()
	return
	#queue_free()

## Misc
func spawn_shards() -> void: #Array[BasicBullet]:
	if num_shards <= 0: return #numshards must be >0
	# Tau is just 2π, this is finding an even spacing of angles for the shards to be spawned
	var step := TAU / float(num_shards)
	# Center the spread around 'base' direction, randomness adds variability to spray inital direction to look better
	var start := dir.angle() - 0.5 * step * (num_shards - 1)
	
	for i in range(num_shards):
		#add randomness to spread to keep visually interesting
		var a := start + i * step * RandomNumberGenerator.new().randf_range(0.8,1.2)
		var v := Vector2.RIGHT.rotated(a)  # unit direction at angle a
		var bb : BasicBullet = BasicBullet.instantiate(global_position, shard_speed, v, shard_lifetime)
		bb.source_tank_id = source_tank_id   # preserve ownership 
		shards.append(bb)	#add to shards array referece

	return

#remove all shards from multibullet
func despawn_shards():
	print("get rid of em")
	for s in shards:
		print("shard removed")
		s.queue_free()

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
