extends Area2D   

#An area that when a bullet enters the area the barrel object is deleted and bullets are spawned in all directions

#variables
var bullets : Array[BasicBullet] = []


func explode() :
	update_bullets()

	#instantiate 8 bullets
	for n in range(8):
		var angle = deg_to_rad(n*45)#get the 45 degree angle in radians
		var direction = Vector2.RIGHT.rotated(angle)#get the vector for the bullet
		var b = BasicBullet.instantiate(global_position, 125.0, direction, 7.0)
		bullets.append(b)
		
	#remove the barrel
	queue_free()
	


func update_bullets() :
	#iterates backwards through the array to safely through the array and delete all invalid nodes (bullets that have destroyed themselves)
	for i in range(bullets.size() - 1, -1, -1) :
		if !is_instance_valid(bullets[i]):
			bullets.remove_at(i)


func _on_body_entered(body: Node2D) -> void:
	#check if the area is entered by a bullet:
	if body is BasicBullet:
		#spawn bullets and delete barrel
		explode()
		
