extends Node2D

@export var speed = 10

func _process(delta: float) -> void:
	rotate(delta * speed)
