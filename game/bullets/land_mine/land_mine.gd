extends RigidBody2D
class_name LandMine

@onready var hitbox : Area2D = $Hitbox
@onready var sprite : Sprite2D = $LandMineSprite

var source_tank_id : int = -1
var source_tank_invincible : bool = true #this will get turned off 0.1 seconds after the bullet is shot, prevents tanks from accidentally shooting themselves unless they are going way faster than their own bullets
# control how long player is invincible after planting land mine
# if player who planted mine cannot trigger, then this is unessesary
var delay_when_plant : float = 1
# control how long the mine takes to explode after being triggered
# if it is immediate, then this is unnessesary
var delay_when_trig : float = 0
var dissolve_delay : float = 0.05

#region - variables for the spawned shards
var num_shards : int = 8
var shard_speed : float = 100.0
var shard_lifetime : float = 1.5
var exploded : bool = false
var shards : Array[BasicBullet] = []
#endregion

func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)
	hitbox.area_exited.connect(on_area_exited)
	hitbox.area_entered.connect(on_area_entered)
	linear_velocity = Vector2(0,0);
	#source tank invincibility
	await get_tree().create_timer(delay_when_plant).timeout
	source_tank_invincible = false

# right now this function does nothing...
# presumes all land mines will stay until end of round
#func _process(delta):
	#pass

func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		# TODO: Do we want players to be able to be hit by their own mines?
		if tank.id == source_tank_id && source_tank_invincible :
			return #a tank can't destroy itself with its own land mine for a brief moment after the mine has been laid
		AudioManager.play(Ref.landmine_stepped_on_sfx)

# aka when a opponent (or any?) tank comes within the range of the landmine
func on_area_exited(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		# TODO: Do we want players to be able to be hit by their own mines?
		if tank.id == source_tank_id && source_tank_invincible :
			return #a tank can't destroy itself with its own land mine for a brief moment after the mine has been laid
		#waits time before exploding mine, would be fun if tank is fast and can avoid
		#tank.die()
		AudioManager.play(Ref.landmine_explode_sfx)
		await get_tree().create_timer(0.1).timeout
		call_deferred("spawn_shards")
		#wait for tank to despawn so that bullet shards dont hit player

func dissolve_sprite() -> void:
	while (sprite.modulate.a > 0):
		await get_tree().create_timer(dissolve_delay).timeout
		sprite.modulate.a -= 0.05

func spawn_shards() -> void: #Array[BasicBullet]:
	if num_shards <= 0: return #numshards must be >0
	# Tau is just 2π, this is finding an even spacing of angles for the shards to be spawned
	var step := TAU / float(num_shards)
	# Center the spread around 'base' direction, randomness adds variability to spray inital direction to look better
	
	for i in range(num_shards):
		#add randomness to spread to keep visually interesting
		var angle := i * step
		var dir_vect := Vector2(cos(angle), sin(angle))
		var bb : BasicBullet = BasicBullet.instantiate(global_position, shard_speed, dir_vect, shard_lifetime)
		bb.source_tank_id = source_tank_id   # preserve ownership 
		shards.append(bb)	#add to shards array referece
		
	queue_free()
	return
	
func on_end_of_round() :
	queue_free()
	
static func instantiate(position_ : Vector2) -> LandMine :
	var lm : LandMine = Ref.land_mine.instantiate()
	lm.position = position_
	Global.Entities.add_child(lm)
	lm.dissolve_sprite()
	return lm
