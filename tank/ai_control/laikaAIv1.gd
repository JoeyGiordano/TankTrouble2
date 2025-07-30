extends Node2D
class_name LaikaAIv1

@onready var tank : Tank = get_parent()

#tanks are designed to be easily controlled by code (by virtually pressing the keys in _process())
#all you have to do is add this node as a child of a tank

#right now he just goes in circles

func _process(delta):
	Input.action_press(tank.get_input_tag("_left"))
	Input.action_press(tank.get_input_tag("_down"))
