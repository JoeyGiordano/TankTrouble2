extends Node
class_name Tank

@export var tank_id = 0 # 1,2,3,etc for player; -1,-2,-3,etc for non-player

var stats #TODO
@onready var tank_rigidbody : TankRigidbody = $TankRigidbody
@onready var gun_holder : GunHolder = $TankRigidbody/GunHolder
static var tank_scene : PackedScene = preload("res://game/tank/tank.tscn")

var move_input : Vector2 = Vector2.ZERO

var input_locked = false #allows/disallows player/npc script from controlling tank, should be used for scene transitions etc


func _ready() :
	ensure_input_map()

func _process(delta):
	get_movement_input()

func _physics_process(delta):
	if !input_locked :
		tank_rigidbody.move_and_rotate()
		if Input.is_action_just_pressed(get_input_tag("_shoot")) :
			gun_holder.get_current_gun().shoot()

#INPUT

func get_movement_input() :
	move_input.x = Input.get_axis(get_input_tag("_left"), get_input_tag("_right"))
	move_input.y = Input.get_axis(get_input_tag("_down"), get_input_tag("_up"))

func ensure_input_map() :
	#checks to see if there are already input actions in the input map for this tank
	#if there are none, creates them
	if InputMap.has_action(get_input_tag()+"_left") : return #if it already has one, assume it has all of them
	#create input map actions. these can be triggered in code by an npc tank
	InputMap.add_action(get_input_tag("_left"))
	InputMap.add_action(get_input_tag("_right"))
	InputMap.add_action(get_input_tag("_down"))
	InputMap.add_action(get_input_tag("_up"))
	InputMap.add_action(get_input_tag("_shoot"))

func get_input_tag(action : String = "") -> String :
	return "tank" + str(tank_id) + action

#MISC RESOURCE
func lock() :
	#disallows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true
	
func unlock() :
	#allows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true

func is_player() -> bool :
	return tank_id > 0

func is_npc() -> bool :
	return tank_id < 0

static func instantiate_tank(parent : Node , is_player_ : bool , player_id_ : int) -> Tank :
	#create a new tank and return it
	#instantiate a tank from the .tscn #GameContainer.GC.
	var t : Tank = tank_scene.instantiate() #have to call to game container here bc this method is static
	#set the variables
	t.tank_id = player_id_
	#add the new tank to the scene tree
	parent.add_child(t)
	return t
	
