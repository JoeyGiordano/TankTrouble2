extends Node2D
class_name DefaultGun

func _ready():
	pass
	
func _process(delta):
	if control.shoot :
		Bullet.instantiate_bullet(guntip, 100, tank_rigidbody.transform.x)

	
