extends TankLoadout
class_name LandMineTankLoadout

@onready var guntip = $Guntip

var mines : Array[LandMine] = []
var man_num_mines : int = 3
# if multibullet is not remotely detonated, or the remote detonation has occured, remote should be set false

func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)

#deploy the mine
func shoot() :
	var lm = LandMine.instantiate(guntip.global_position)
	lm.source_tank_id = tank.id
	mines.append(lm)
	if mines.size() == man_num_mines:
		set_basic_loadout()

func on_end_of_round() :
	set_basic_loadout()

func set_basic_loadout() :
	tank.change_loadout("basic_loadout")
	
