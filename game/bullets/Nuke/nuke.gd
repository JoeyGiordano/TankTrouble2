extends RigidBody2D
class_name Nuke

@onready var sprite : Sprite2D = $nuke_shadow_sprite

var source_tank_id : int = -1
var source_tank_invincible : bool = true #this will get turned off 0.1 seconds after the bullet is shot, prevents tanks from accidentally shooting themselves unless they are going way faster than their own bullets
# control how long player is invincible after planting land mine
# if player who planted mine cannot trigger, then this is unessesary
var nuke_delay : int = 6


func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)
	linear_velocity = Vector2(0,0)
	increase_shadow()
	kill_all_tanks()

func kill_all_tanks() -> void:
	await get_tree().create_timer(nuke_delay).timeout
	AudioManager.play(Ref.nuke_explode_sfx)
	var all_tanks : Array[Tank] = TankManager.get_all_tanks()
	for t in all_tanks:
		t.die()
	queue_free()

func on_end_of_round() :
	queue_free()
	
# round end
func increase_shadow() -> void:
	sprite.modulate.a = 0
	while (sprite.scale.x < 1):
		await get_tree().create_timer(0.05).timeout
		sprite.scale.x += 0.01
		sprite.scale.y += 0.01
		if (sprite.modulate.a < 1):
			sprite.modulate.a += 0.01
		
	

	
static func instantiate(position_ : Vector2) -> Nuke :
	var n : Nuke = Ref.nuke.instantiate()
	n.position = position_
	Global.Entities.add_child(n)
	return n
