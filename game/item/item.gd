extends Node2D
class_name Item

@export var item_res : ItemResource

@onready var hitbox : Area2D = $Hitbox

func _ready():
	hitbox.area_entered.connect(on_area_entered)

func get_stats() -> Stats :
	return item_res.get_stats()

func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		call_deferred("pickup", tank)
		
func pickup(tank : Tank) :
	tank.pickup_item(self)
