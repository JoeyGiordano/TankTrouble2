extends TankLoadout
class_name MultiTankLoadout

@onready var guntip = $Guntip

var multibullets : Array[MultiBullet] = []
# if multibullet is not remotely detonated, or the remote detonation has occured, remote should be set false
@export var remote : bool = false
var has_fired : bool = false
var last_shot : MultiBullet = null

func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)

func shoot() :
	if not has_fired:
		var b = MultiBullet.instantiate(guntip.global_position, tank.stats.bullet_speed, tank_rigidbody.forward(), tank.stats.bullet_lifetime, remote)
		b.source_tank_id = tank.id
		last_shot = b
		has_fired = true
	
	
	if has_fired and not remote: # if bullet wasnt remote, then revert to basic after shot
		set_basic_loadout()
	elif remote and has_fired and last_shot: # if bullet is remote and has been triggered
		last_shot.remote_detonate()
		set_basic_loadout()

func on_end_of_round() :
	set_basic_loadout()

func set_basic_loadout() :
	tank.change_loadout("basic_loadout")
	
