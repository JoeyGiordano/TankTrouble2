extends Node2D
class_name GunHolder

func get_current_gun() -> Gun :
	return get_child(0)
