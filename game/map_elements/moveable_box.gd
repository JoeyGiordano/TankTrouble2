extends Node2D

#An area that when a bullet enters the area the box and bullet are removed
func _on_area_2d_body_entered(body: Node2D) -> void:
	#check if the area is entered by a bullet:
	if body is BasicBullet:
		#remove the box and bullet
		queue_free()
		body.queue_free()
