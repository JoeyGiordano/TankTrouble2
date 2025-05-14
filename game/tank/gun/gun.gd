extends Node2D
class_name Gun

@onready var tank : Tank = get_parent().get_parent().get_parent()

func shoot() :
	#should be overrode
	print("shot fired")

func tank_forward() -> Vector2 :
	return tank.tank_rigidbody.transform.x

func tank_left() -> Vector2 :
	return tank.tank_rigidbody.transform.y

func tank_right() -> Vector2 :
	return -tank.tank_rigidbody.transform.y
	
func tank_backward() -> Vector2 :
	return -tank.tank_rigidbody.transform.x
	
	
