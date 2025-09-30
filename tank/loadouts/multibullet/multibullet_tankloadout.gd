extends TankLoadout
class_name MultiTankLoadout

@onready var guntip = $Guntip

var multibullets : Array[MultiBullet] = []

func shoot() :
	#update_bullets()
	if multibullets.size() == 3 : return
	
	var b = MultiBullet.instantiate(guntip.global_position, tank.stats.bullet_speed, tank_rigidbody.forward(), tank.stats.bullet_lifetime)
	multibullets.append(b)
	b.source_tank_id = tank.id
	#play shoot sound and anim
	#set the variables


func update_bullets() :
	#iterates backwards through the array to safely through the array and delete all invalid nodes (bullets that have destroyed themselves)
	for i in range(multibullets.size() - 1, -1, -1) :
		if !is_instance_valid(multibullets[i]):
			multibullets.remove_at(i)
