extends Node2D


@onready var hitbox : Area2D = $Area2D

var t : Tank

func _ready():
	hitbox.area_entered.connect(on_area_entered)
	hitbox.area_exited.connect(on_area_exited)
	
func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		tank.give_invincibility()

	
	
func on_area_exited(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		tank.remove_invincibility()
