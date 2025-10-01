extends Node2D

@export var speed_mod : Vector2





func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is BasicBullet):
		body.linear_velocity *= speed_mod
