extends Node
class_name EffectsHandler

var on_fire : bool = false

func _process(delta):
	
	if Input.is_key_pressed(KEY_F) : on_fire = true
	else : on_fire = false
