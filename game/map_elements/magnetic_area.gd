extends Node2D

@export var magnetic_strength : int
#If checked, the bullets entering will experience a clockwise rotation, if not checked, a counter-clockwise rotation
@export var clockwise_rotation : bool
var bullets_in_field: Array = []



#If the bullet is in the field, add a velocity perpendicular to its movtion to make the bullet curve
func _physics_process(_delta):
	for bullet in bullets_in_field:
		var v = bullet.linear_velocity
		var perpendicular = Vector2(-v.y, v.x)

		if clockwise_rotation:
			v += perpendicular * magnetic_strength * _delta
		else:
			v += perpendicular * magnetic_strength * _delta * -1

		bullet.linear_velocity = v


#adds the bullet to the array when it enters the field
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is BasicBullet or MultiBullet):
		if body not in bullets_in_field:
			bullets_in_field.append(body)


#removes the bullet from the array when it exits the field
func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is BasicBullet or MultiBullet):
		bullets_in_field.erase(body)
