extends TankLoadout
class_name NukeTankLoadout

@onready var guntip = $Guntip

func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)

#deploy the mine
func shoot() :
	var n = Nuke.instantiate(guntip.global_position)
	n.source_tank_id = tank.id
	AudioManager.play(Ref.nuke_shoot_sfx)
	set_basic_loadout()

func on_end_of_round() :
	set_basic_loadout()

func set_basic_loadout() :
	tank.change_loadout("basic_loadout")
	
