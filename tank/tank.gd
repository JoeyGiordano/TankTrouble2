extends Node
class_name Tank

var is_player = true #in case of NPC tanks
var player_id = 0 #0 for non player, 1,2,3,etc for player

var stats #TODO
var control : TankControlScheme
@onready var tank_rigidbody: TankRigidbody = $TankRigidbody

func _ready() :
	control.tank = self

func _process(delta):
	control.update_inputs()

static func instantiate_tank(is_player_ : bool , player_id_ : int) -> Tank :
	#create a new tank and return it so it can be childed by whatever called this method
	#instantiate a tank from the .tscn
	var t : Tank = GameContainer.GAME_CONTAINER.tank_scene.instantiate() #have to call to game container here bc this method is static
	#set the variables
	t.is_player = is_player_
	t.player_id = player_id_
	#give it a control scheme
	if is_player_ :
		t.control = PlayerControl.new()
	
	return t
	
