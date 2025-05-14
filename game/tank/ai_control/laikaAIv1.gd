extends Node2D
class_name LaikaAIv1

@onready var tank : Tank = get_parent()

#right now he just goes in circles

func _process(delta):
	Input.action_press(tank.get_input_tag("_left"))
