extends Node
class_name Tank

## The Tank class is the control center for the tank. This script is attached to the Tank Node.
## This class manages the internal state of the tank (including the state of the Tank Nodes children)
## and acts as a point of contact for external nodes to reference inside tank and act on its state.
## It is a set structure (ie we always know the hierarchy of nodes under tank) which makes it easy
## for internal and external nodes. Anything that is added to this script should only affect the internal
## state of the tank and should NOT affect the state of external nodes, to compartmentalize, prevent 
## clutter, and make it harder to leave out of date code here. A good example is Item, which when picked
## up completely manages adding itself into the items list and giving the boost to the stats_handler,
## instead of having a pickup_item(Item) function in tank that does that stuff.

@export var id = 0 # 1,2,3,etc for player; -1,-2,-3,etc for non-player
#MUST set stats resource local_to_scene=true. MUST put the starting stats in as a NOT saved resource. if you want to use a saved resource, you must load it in init(). A normal saved exported resource loads too late, initializing in _ready() is also too late: it will cause an error when it tries to get accessed, preload causes a cyclic error with stat_boost static functions 
@export var stats : StatBoost # we use a stat boost to store the tanks stats (it holds all the info we need it to hold)

@onready var tank_rigidbody : TankRigidbody = $TankRigidbody
@onready var items : Node = $Items
@onready var stats_handler : StatsHandler = $StatsHandler
@onready var effects_handler : EffectsHandler = $EffectsHandler
static var tank_scene : PackedScene = preload("res://tank/tank.tscn")

#Input
var move_input : Vector2 = Vector2.ZERO

#Flags
var input_locked = false #allows/disallows input map input from controlling tank, should be used for scene transitions etc
var dead = false

func _ready() :
	GameManager.begin_round.connect(on_begin_round)
	GameManager.end_round.connect(on_end_round)
	ensure_input_map()
	lock()
	despawn() #just hides them from view and disables their rigidbody interactions

func _process(_delta) :
	DEBUG_PROCESS()
	get_movement_input()
	#shoot logic
	if Input.is_action_just_pressed(get_input_tag("_shoot")) :
		shoot()
	if Input.is_action_just_released(get_input_tag("_shoot")) :
		end_shoot() #for loadouts where the release of the shoot hey also has an effect

func _physics_process(_delta):
	tank_rigidbody.move_and_rotate()

func DEBUG_PROCESS() :
	#place to put debug controls
	#don't leave debug features in here when you merge (unless its something for everybody to use)
	if Input.is_action_just_pressed("DEBUG_COMMAND") && id == 2: #for this if, you have to press 9 before debug command
		if Input.is_key_pressed(KEY_9) :
			change_loadout(TankLoadout.Type.EMPTY)
		if Input.is_key_pressed(KEY_8) :
			change_loadout(TankLoadout.Type.BASIC)

#MISC

func shoot() :
	tank_rigidbody.get_loadout().shoot()

func end_shoot() :
	tank_rigidbody.get_loadout().end_shoot()
	
func change_loadout(type : TankLoadout.Type) :
	tank_rigidbody.replace_loadout(type)


#INPUT

func get_movement_input() :
	move_input.x = Input.get_axis(get_input_tag("_left"), get_input_tag("_right"))
	move_input.y = Input.get_axis(get_input_tag("_down"), get_input_tag("_up"))

func ensure_input_map() :
	#checks to see if there are already input ons in the input map for this tank
	#if there are none, creates them
	#this way, if a tank is not one of the player tanks, it will have input actions that can be accessed by an NPC/AI controller node
	if InputMap.has_action(get_input_tag()+"_left") : return #if it already has one, assume it has all of them
	#create input map actions. these can be triggered in code by an npc tank
	InputMap.add_action(get_input_tag("_left"))
	InputMap.add_action(get_input_tag("_right"))
	InputMap.add_action(get_input_tag("_down"))
	InputMap.add_action(get_input_tag("_up"))
	InputMap.add_action(get_input_tag("_shoot"))

func get_input_tag(action : String = "") -> String :
	return "tank" + str(id) + action

# MAJOR STATE

func on_begin_round() :
	#response to GM.begin_round signal
	#all of the relevant bools should get set here
	#it should be spawned in by the level
	dead = false
	unlock()

func on_end_round() :
	#called at the end of every round
	#all of the relevant bools should get set here
	lock()
	despawn()

func die() :
	lock()
	#play death sound and anim
	despawn()
	dead = true
	GameManager.level.tank_died()

#MINOR STATE

func lock() :
	#disallows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true
	tank_rigidbody.lock()

func unlock() :
	#allows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true
	tank_rigidbody.unlock()

func respawn(position : Vector2) :
	tank_rigidbody.teleport_to(position)
	tank_rigidbody.show()

func despawn() :
	tank_rigidbody.hide()
	tank_rigidbody.teleport_to(Vector2(10000000, id * 100)) #to get the collision shapes out of the way. Easier than changing the collision masks. It works so...

#RESOURCE

func is_player() -> bool :
	return id > 0

func is_npc() -> bool :
	return id < 0

static func instantiate_tank(parent : Node , id_ : int) -> Tank :
	#create a new tank and return it
	#instantiate a tank from the .tscn #GameContainer.GC.
	var t : Tank = tank_scene.instantiate() #have to call to game container here bc this method is static
	#set id
	t.id = id_
	#add the new tank to the scene tree
	parent.add_child(t)
	return t
