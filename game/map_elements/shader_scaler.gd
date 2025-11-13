@tool
extends Sprite2D

func _process(_delta: float) -> void:
	if material:
		material.set_shader_parameter("node2d_scale", scale)
