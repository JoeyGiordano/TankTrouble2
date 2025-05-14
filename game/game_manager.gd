extends Node
class_name GameManager

#easy way to access the GameManager from other nodes
static var GM : GameManager

var player_count : int
var score : int

func _init():
	#set up the singleton (not an autoload) (in _init() so that it works when _ready() is called for all other nodes)
	GM = self

func _process(delta):
	
	#DEBUG - allows skipping the Game scene
	if GameContainer.GC.ActiveSceneHolder.get_child(0).name == "Game" && Input.is_action_just_pressed("DEBUG_SKIP"):
		victory_achieved(1)

func player_ready() :
	#gets called from the ready_up screen
	#assume two players for now
	GameContainer.GC.switch_to_scene("game")
	GameContainer.GC.create_players(2)
	player(1).tank_rigidbody.global_position = Vector2(-100,0)

func victory_achieved(player_id : int) :
	GameContainer.GC.destroy_all_players()
	GameContainer.GC.switch_to_scene("victory")

func player(tank_id : int) -> Tank :
	#gets player with given tank_id, tank_ids lower than 1 are not players
	for i in GameContainer.GC.Players.get_child_count() :
		if GameContainer.GC.Players.get_child(i).tank_id == tank_id :
			return GameContainer.GC.Players.get_child(i)
	return null
