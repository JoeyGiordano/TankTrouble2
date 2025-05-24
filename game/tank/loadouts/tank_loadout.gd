extends CollisionPolygon2D
class_name TankLoadout

static var empty : PackedScene = preload("res://game/tank/loadouts/empty_tankloadout.tscn")
static var basic : PackedScene = preload("res://game/tank/loadouts/basic/basic_tankloadout.tscn")

enum Type {
	EMPTY,
	BASIC
}

@onready var tank_rigidbody : TankRigidbody = get_parent()

func shoot() :
	#should be overridden by child class
	#print("shot fired")
	pass

func end_shoot() :
	#can be overridden by child class
	#print("shoot button lifted")
	pass

static func instantiate(parent : RigidBody2D, type : Type) -> TankLoadout :
	#should be overriden by child class
	var tl : TankLoadout
	match type :
		Type.EMPTY :
			tl = empty.instantiate()
		Type.BASIC :
			tl = basic.instantiate()
		_ :
			tl = basic.instantiate()
	parent.add_child(tl)
	return tl
