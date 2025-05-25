extends CollisionPolygon2D
class_name TankLoadout

#packed scenes of loadout types (except basic, see below)
static var empty : PackedScene = preload("res://game/tank/loadouts/empty_tankloadout.tscn")

#loadout type enum, one for each packed scene
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
			tl = instantiate_basic() #DO NOT DELETE. See method comment
		_ :
			tl = empty.instantiate()
	parent.add_child(tl)
	return tl

static func instantiate_basic() -> TankLoadout :
	# You might be thinking "oh this is silly, why is he preloading the other scenes but this one is getting loaded in its own special way"
	# and while you would be right to think that DO NOT CHANGE THIS. For some reason trying to preload this scene and then instantiate it doe not work
	# it just leaves you with an error like "failed to instantiate scene state of "", node count is 0". If you know the solution (read this all the way through)
	# sure try to go ahead an fix it AFTER BRANCHING. If you don't, and think you can, think again. I spent two hours trying to no avail. If you do try, MAKE A NEW BRANCH.
	var x := load("res://game/tank/loadouts/basic/basic_tankloadout.tscn")
	return x.instantiate()
