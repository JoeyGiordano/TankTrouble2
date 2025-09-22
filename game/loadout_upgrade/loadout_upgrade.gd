extends Node2D
class_name LoadoutUpgrade

@export var color : Color
@export var loadout_name : String = "basic_loadout"

@onready var hitbox : Area2D = $Hitbox

func _ready():
	hitbox.area_entered.connect(on_area_entered)
	hitbox.get_child(0).modulate = color

func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		get_pickedup_by(tank)
		
func get_pickedup_by(tank : Tank) :
	tank.change_loadout(loadout_name)
	queue_free()
