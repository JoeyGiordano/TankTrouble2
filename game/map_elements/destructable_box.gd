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
		#remove if health = 0
		if(health == 0):
			queue_free()
