extends Node2D
#An area that when a bullet enters the area the barrel object is deleted and bullets are spawned in all directions

#variables
#health of the box
@export var health : int
var bullets : Array[BasicBullet] = []



func explode() :

	#instantiate 8 bullets
	for n in range(8):
		var angle = deg_to_rad(n*45)#get the 45 degree angle in radians
		var direction = Vector2.RIGHT.rotated(angle)#get the vector for the bullet
		var b = BasicBullet.instantiate(global_position, 125.0, direction, 7.0)
		bullets.append(b)
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	#check if the area is entered by a bullet:
	if body is BasicBullet:
		#remove the bullet
		body.queue_free()
		#update health
		health -= 1
		#explode if health = 0
		if(health == 0):
			queue_free()
			#spawn bullets
			explode()
