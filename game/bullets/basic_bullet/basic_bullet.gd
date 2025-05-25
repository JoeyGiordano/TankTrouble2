extends RigidBody2D
class_name BasicBullet

static var bullet_scene = preload("res://game/bullets/basic_bullet/basic_bullet.tscn")

@onready var hitbox : Area2D = $Hitbox

var speed : float
var dir : Vector2
var lifetime : float #lifetime in seconds

func _ready():
	body_entered.connect(on_body_entered)
	hitbox.area_entered.connect(on_area_entered)
	linear_velocity = speed * dir.normalized()

func _process(delta):
	lifetime -= delta
	if lifetime <= 0 :
		#play bullet disappread sound and anim
		queue_free()

func on_body_entered(body : Node) : #contact_monitor must be set to true and max_contacts_reported must be >0
	return
	print(body.name)
	if body is TankRigidbody :
		assert(body is TankRigidbody)
		body.tank.die()
		queue_free()

func on_area_entered(area : Area2D) : #contact_monitor must be set to true and max_contacts_reported must be >0
	if area.is_in_group("tank_hitbox") :
		var tank : Tank = area.get_parent().tank_rigidbody.tank #all tank hitboxes must be direct children of a tank loadout
		tank.die()
		queue_free()

static func instantiate(position_ : Vector2 , speed_ : float, dir_ : Vector2, lifetime_ : float) -> BasicBullet :
	#create a new bullet and return it
	#instantiate a tank from the .tscn
	var b : BasicBullet = bullet_scene.instantiate() #have to call to game container here bc this method is static
	
	#set the variables
	b.speed = speed_
	b.dir = dir_
	b.position = position_
	b.lifetime = lifetime_
	
	#add the new bullet to the scene tree in the correct place
	GameManager.GM.Bullets.add_child(b)
	return b
	
	
