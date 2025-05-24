extends Node
class_name Tank

@export var id = 0 # 1,2,3,etc for player; -1,-2,-3,etc for non-player

var stats #TODO
@onready var tank_rigidbody : TankRigidbody = $TankRigidbody
static var tank_scene : PackedScene = preload("res://game/tank/tank.tscn")

var collision_mask : int
var move_input : Vector2 = Vector2.ZERO
var input_locked = false #allows/disallows input map input from controlling tank, should be used for scene transitions etc
var dead = false

func _ready() :
	ensure_input_map()
	collision_mask = tank_rigidbody.collision_mask #save the normal collision mask for later

func _process(delta):
	DEBUG_PROCESS()
	get_movement_input()
	#shoot logic
	if Input.is_action_just_pressed(get_input_tag("_shoot")) :
		shoot()
	if Input.is_action_just_released(get_input_tag("_shoot")) :
		end_shoot() #for loadouts where the release of the shoot hey also has an effect

func _physics_process(delta):
	if !input_locked :
		tank_rigidbody.move_and_rotate()

func DEBUG_PROCESS() :
	#place to put debug controls
	if Input.is_action_just_pressed("DEBUG_COMMAND") : #for this if, you have to press 9 before debug command
		if Input.is_key_pressed(KEY_9) :
			change_loadout(TankLoadout.Type.EMPTY)
		if Input.is_key_pressed(KEY_0) :
			change_loadout(TankLoadout.Type.DEFAULT)
		

## Misc Methods

func begin_round(position : Vector2) :
	#called at the beginning of every round
	#all of the relevant bools should get set here
	dead = false
	change_loadout(TankLoadout.Type.DEFAULT)
	add_to_game(position)
	unlock()

func end_round() :
	#called at the end of every round
	#all of the relevant bools should get set here
	lock()
	remove_from_game()

func die() :
	lock()
	#play death sound and anim
	remove_from_game()
	dead = true
	GameManager.GM.tank_died()

func shoot() :
	tank_rigidbody.get_loadout().shoot()

func end_shoot() :
	tank_rigidbody.get_loadout().end_shoot()
	
func change_loadout(type : TankLoadout.Type) :
	tank_rigidbody.replace_loadout(type)

##INPUT

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
	return "tank" + str(id) + action

##MISC RESOURCE

func lock() :
	#disallows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true

func unlock() :
	#allows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true
	
func remove_from_game() :
	tank_rigidbody.hide()
	tank_rigidbody.teleport_to(Vector2(10000000, id * 100))# = Vector2(10000000, id * 100) #to get the collision shapes out of the way. I couldn't find a way to disable them that prevents them from being detected by on_body_entered, which is what bullets use to see that they've hit a tank (yes, I've already tried changing the collision_mask). This works so...
	
func add_to_game(position : Vector2) :
	tank_rigidbody.position = position
	tank_rigidbody.show()

func is_player() -> bool :
	return id > 0

func is_npc() -> bool :
	return id < 0

static func instantiate_tank(parent : Node , id : int) -> Tank :
	#create a new tank and return it
	#instantiate a tank from the .tscn #GameContainer.GC.
	var t : Tank = tank_scene.instantiate() #have to call to game container here bc this method is static
	#set id
	t.id = id
	#add the new tank to the scene tree
	parent.add_child(t)
	return t
