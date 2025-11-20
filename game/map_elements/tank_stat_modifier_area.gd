extends Node2D


@export var boost : StatBoost

@onready var hitbox : Area2D = $Hitbox

var t : Tank

func _ready():
	hitbox.area_entered.connect(on_area_entered)
	hitbox.area_exited.connect(on_area_exited)
	


func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		give_effect(tank)
	
		
func on_area_exited(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		lose_effect(tank)	
		

func give_effect(tank : Tank) :
	tank.stats_handler.add_boost_stats(boost)
	
	
func lose_effect(tank : Tank) :
	tank.stats_handler.subtract_boost_stats(boost)




#other way
#	var bh : BoostHolder = tank.stats_handler.add_boost_with_source(boost, self)
#	tank.stats_handler.remove_boost(bh)
