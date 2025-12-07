extends Node2D

#An area that when a bullet enters the area the bullet is removed
func _on_area_2d_body_entered(body: Node2D) -> void:
	#check if the area is entered by a bullet:
	if body is BasicBullet:
		#remove the bullet
		AudioManager.play(Ref.indestructible_box_hit_sfx)
		body.queue_free()
