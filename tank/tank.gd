extends Node
class_name Tank

### Tank ##
## The control center for a tank. This script is attached to the Tank Node.
## This class manages the internal state of the tank (including the state of the Tank Nodes children)
## and acts as a point of contact for external nodes to reference inside tank and act on its state.
## It is a set structure (ie we always know the hierarchy of nodes under tank) which makes it easy
## for internal and external nodes. Anything that is added to this script should only affect the internal
## state of the tank and should NOT affect the state of external nodes, to compartmentalize, prevent 
## clutter, and make it harder to leave out of date code here. A good example is Item, which when picked
## up completely manages adding itself into the items list and giving the boost to the stats_handler,
## instead of having a pickup_item(Item) function in tank that does that stuff.

# Base stuff (set at instantiation)
@export var scene_file_tank : bool = false #switch this to true for tanks that are placed in a scene tree manually in a scene file
var id : int # will always be unique, never modified
@export var profile : TankProfile = TankProfile.new()
@export var stats : StatBoost = Ref.base_tank_stats.copy() # we use a stat boost to store the tanks stats (it holds all the info we need it to hold) # -> an old comment that I thought was interesting -> #MUST set stats resource local_to_scene=true. MUST put the starting stats in as a NOT saved resource. if you want to use a saved resource, you must load it in init(). A normal saved exported resource loads too late, initializing in _ready() is also too late: it will cause an error when it tries to get accessed, preload causes a cyclic error with stat_boost static functions 

# Important references
@onready var tank_rigidbody : TankRigidbody = $TankRigidbody
@onready var items : Node = $Items
@onready var stats_handler : StatsHandler = $StatsHandler
@onready var effects_handler : EffectsHandler = $EffectsHandler

# Input
var move_input : Vector2 = Vector2.ZERO

# Flags
var input_locked : bool = false #allows/disallows input map input from controlling tank, should be used for scene transitions etc
var dead : bool = false

func _init() :
	if scene_file_tank : TankManager.register_scene_file_npc_tank(self) # handle tanks that are in the scene files (not created by TankManager), mostly for debug, also possibly for campaign later

func _ready() :
	GameManager.beginning_of_round.connect(on_beginning_of_round)
	GameManager.end_of_round.connect(on_end_of_round)
	if scene_file_tank : 
		respawn(tank_rigidbody.position)
	else :
		despawn() #just hides them from view, locks input, and disables their rigidbody interactions

func _process(_delta) :
	DEBUG_PROCESS()
	detect_player_input()

func _physics_process(_delta):
	tank_rigidbody.move_and_rotate()

func DEBUG_PROCESS() :
	#place to put debug stuff
	pass

## Input

func set_move_input(new_move_input : Vector2) :
	if input_locked : return
	move_input = new_move_input

func set_move_input_x(new_move_x : float) :
	if input_locked : return
	move_input = Vector2(new_move_x, move_input.y)

func set_move_input_y(new_move_y : float) :
	if input_locked : return
	move_input = Vector2(move_input.x, new_move_y)

func shoot() :
	if input_locked : return
	tank_rigidbody.get_loadout().shoot()

func end_shoot() :
	if input_locked : return
	# simulation of when the shoot button is lifted
	tank_rigidbody.get_loadout().end_shoot()

## Player Input

func detect_player_input() :
	# only real human players are controlled through input map and the keyboard. Bots are controlled through direct method calls
	if !profile.is_player() : return
	
	move_input.x = Input.get_axis(profile.key_LEFT, profile.key_RIGHT)
	move_input.y = Input.get_axis(profile.key_DOWN, profile.key_UP)
	
	if Input.is_action_just_pressed(profile.key_SHOOT) :
		shoot()
	if Input.is_action_just_released(profile.key_SHOOT) :
		end_shoot() #for loadouts where the release of the shoot hey also has an effect

## Misc

func change_loadout(type : TankLoadout.Type) :
	tank_rigidbody.replace_loadout(type)

func destroy() :
	TankManager.destroy_tank(self)

## Signal Response

func on_beginning_of_round() :
	dead = false
	unlock()

func on_end_of_round() :
	despawn()

## State

func die() :
	lock()
	#play death sound and anim
	despawn()
	dead = true
	GameManager.tank_died()

func despawn() :
	lock()
	tank_rigidbody.hide()
	tank_rigidbody.teleport_to(Vector2(10000000, 10000000 + id * 100)) #to get the collision shapes out of the way. Easier than changing the collision masks. It works so...

func respawn(position : Vector2) :
	tank_rigidbody.teleport_to(position)
	tank_rigidbody.show()

func lock() :
	#disallows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = true
	tank_rigidbody.lock()

func unlock() :
	#allows player/npc script from controlling tank, should be used for scene transitions etc
	input_locked = false
	tank_rigidbody.unlock()
