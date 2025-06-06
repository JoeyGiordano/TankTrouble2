extends Node
class_name EffectsHandler

@onready var tank : Tank = get_parent()

var on_fire : bool = false
var frozen : bool = false
var electrified : bool = false


func _process(delta) :
	
	if Input.is_key_pressed(KEY_F) : on_fire = true
	else : on_fire = false
	
	if Input.is_key_pressed(KEY_G) :
		frozen = true
		#tank.stats_handler
	else : on_fire = false
	
	if Input.is_key_pressed(KEY_H) : electrified = true
	else : on_fire = false
