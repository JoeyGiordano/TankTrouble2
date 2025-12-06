extends RigidBody2D
class_name Nuke

@onready var sprite : Sprite2D = $nuke_shadow_sprite
@onready var hitbox : Area2D = $Hitbox
@onready var explosion : Node2D = $Explosion

var source_tank_id : int = -1
var source_tank_invincible : bool = true #this will get turned off 0.1 seconds after the bullet is shot, prevents tanks from accidentally shooting themselves unless they are going way faster than their own bullets
# control how long player is invincible after planting land mine
# if player who planted mine cannot trigger, then this is unessesary
var nuke_delay : float = 6.5
var exploded : bool = false


func _ready() :
	GameManager.end_of_round.connect(on_end_of_round)
	linear_velocity = Vector2(0,0)
	increase_shadow()
	hitbox.area_entered.connect(on_area_entered)
	await get_tree().create_timer(nuke_delay).timeout
	exploded = true
	hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = false
	await get_tree().create_timer(7).timeout
	queue_free()

func on_area_entered(area : Area2D) :
	if area.is_in_group("tank_hitbox") :
		area.get_parent().tank_rigidbody.tank.die()

func on_end_of_round() :
	queue_free()
	
# round end
func increase_shadow() -> void:
	await get_tree().create_timer(4.2).timeout
	sprite.modulate.a = 0
	while (!exploded):
		await get_tree().create_timer(0.03).timeout
		var d : float = 0.01
		sprite.scale.x += d
		sprite.scale.y += d
		if (sprite.modulate.a < 1):
			sprite.modulate.a += d
		d*=2
	while explosion.modulate.a < 1 :
		await get_tree().create_timer(0.03).timeout
		explosion.modulate.a += 0.4
	sprite.modulate.a = 0.4
	while sprite.modulate.a > 0 :
		await get_tree().create_timer(0.03).timeout
		explosion.modulate.a = max(explosion.modulate.a-0.06,0)
		sprite.modulate.a -= 0.004

static func instantiate(position_ : Vector2) -> Nuke :
	var n : Nuke = Ref.nuke.instantiate()
	n.position = position_
	Global.Entities.add_child(n)
	return n
