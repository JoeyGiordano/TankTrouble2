extends Node
class_name Tank

var is_player = true #in case of NPC tanks
var player_id = 0 #0 for non player, 1,2,3,etc for player

var stats #TODO
var control : TankControlScheme
@onready var tank_rigidbody : TankRigidbody = $TankRigidbody
static var tank_scene : PackedScene = preload("res://game/tank/tank.tscn")

#state
var controls_enabled : bool = true

func _ready() :
	if !control : control = PlayerControl.new() #for tanks that are made in the editor
		
	control.tank = self

func _process(delta):
	
	if controls_enabled :
		control.update_inputs()
	
	
	#if control.shoot :
		#Bullet.instantiate_bullet(guntip, 100, tank_rigidbody.transform.x)

func die() :
	tank_rigidbody.hide()
	disable_controls()

#RESOURCE
func disable_controls() :
	controls_enabled = false
	
func enable_controls() :
	controls_enabled = true

static func instantiate_tank(parent : Node , is_player_ : bool , player_id_ : int) -> Tank :
	#create a new tank and return it
	#instantiate a tank from the .tscn #GameContainer.GC.
	var t : Tank = tank_scene.instantiate() #have to call to game container here bc this method is static
	#set the variables
	t.is_player = is_player_
	t.player_id = player_id_
	#give it a control scheme
	if is_player_ :
		t.control = PlayerControl.new()
	
	#add the new tank to the scene tree
	parent.add_child(t)
	return t
	
