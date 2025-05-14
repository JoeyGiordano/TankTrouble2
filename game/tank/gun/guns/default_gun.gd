extends Gun
class_name DefaultGun

@onready var guntip : Node2D = $Guntip

var max_bullets : int = 5
var bullets_shot : int = 0

func shoot() :
	if bullets_shot == max_bullets : return
	
	Bullet.instantiate_bullet(guntip, 100, tank_forward())
	bullets_shot += 1

	
