extends TankLoadout
class_name MultiTankLoadout

@onready var guntip = $Guntip

var multibullets : Array[MultiBullet] = []
var shots_used : int = 0
var max_shots : int = 3

func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)
func shoot() :
	#update_bullets()
	#if multibullets.size() == 3 : set to basic bullet loadout
	
	var b = MultiBullet.instantiate(guntip.global_position, tank.stats.bullet_speed, tank_rigidbody.forward(), tank.stats.bullet_lifetime)
	b.source_tank_id = tank.id
	shots_used += 1
	
	# if multibullet has been shot 3 times, then revert back to basic loadout
	if shots_used == max_shots : set_basic_loadout()

func on_end_of_round() :
	set_basic_loadout()

func set_basic_loadout() :
	tank.change_loadout("basic_loadout")
	
