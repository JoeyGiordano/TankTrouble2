extends RigidBody2D
class_name Bullet

static var bullet_scene = preload("res://game/bullet/bullet.tscn")

var speed : float
var dir : Vector2

func _ready():
	body_entered.connect(on_body_entered)
	linear_velocity = speed * dir.normalized()

func on_body_entered(body : Node) : #contact_monitor must be set to true and max_contacts_reported must be >0
	if body is Tank :
		on_hit_tank(body)

func on_hit_tank(t : Tank) :
	pass


static func instantiate_bullet(parent : Node , speed : float, dir : Vector2) :
	#create a new tank and return it
	#instantiate a tank from the .tscn
	var b : Bullet = bullet_scene.instantiate() #have to call to game container here bc this method is static
	
	#set the variables
	b.speed = speed
	b.dir = dir
	
	#add the new tank to the scene tree
	parent.add_child(b)
	return b
	
	
