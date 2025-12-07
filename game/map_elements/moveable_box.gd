extends Node2D

#health of the box
@export var health : int

#An area that when a bullet enters the area the box and bullet are removed
func _on_area_2d_body_entered(body: Node2D) -> void:
	#check if the area is entered by a bullet:
	if body is BasicBullet:
		#remove the bullet
		body.queue_free()
		#update health
		health -= 1
		#explode if health = 0
		if(health == 0):
			AudioManager.play(Ref.box_destroy_sfx)
			queue_free()
		else :
			AudioManager.play(Ref.box_hit_sfx)
