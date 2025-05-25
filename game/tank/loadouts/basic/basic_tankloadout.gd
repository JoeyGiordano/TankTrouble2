extends TankLoadout
class_name BasicTankLoadout

@onready var guntip = $Guntip

var max_bullets : int = 5
var bullets : Array[BasicBullet] = []

func _process(_delta):
	if Input.is_key_pressed(KEY_4) : shoot()

func shoot() :
	update_bullets()
	if bullets.size() == max_bullets : return
	
	var b = BasicBullet.instantiate(guntip.global_position, 100, tank_rigidbody.forward(), 7)
	bullets.append(b)
	#play shoot sound and anim


func update_bullets() :
	#iterates backwards through the array to safely through the array and delete all invalid nodes (bullets that have destroyed themselves)
	for i in range(bullets.size() - 1, -1, -1) :
		if !is_instance_valid(bullets[i]):
			bullets.remove_at(i)
