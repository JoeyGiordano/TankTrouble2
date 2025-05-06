extends Node
class_name GameManager

#easy way to access the GameContainer from other nodes
static var GAME_MANAGER : GameManager
@onready var gc = GameContainer.GAME_CONTAINER

var player_count : int
var score : int

func _ready():
	#set up the singleton (not an autoload)
	GAME_MANAGER = self

func _process(delta):
	if GameContainer.GAME_CONTAINER.ActiveSceneHolder.get_child(0).name == "Game" && Input.is_action_just_pressed("DEBUG_SKIP"):
		victory_achieved(1)
		

func player_ready() :
	#gets called from the ready_up screen
	#assume two players for now
	GameContainer.GAME_CONTAINER.switch_to_scene("game")
	GameContainer.GAME_CONTAINER.create_players(2)
	player(1).tank_rigidbody.global_position = Vector2(-100,0)

func victory_achieved(player_id : int) :
	GameContainer.GAME_CONTAINER.destroy_all_players()
	GameContainer.GAME_CONTAINER.switch_to_scene("victory")

func player(player_id : int) -> Tank :
	#gets player with given player_id
	for i in GameContainer.GAME_CONTAINER.Players.get_child_count() :
		if GameContainer.GAME_CONTAINER.Players.get_child(i).player_id == player_id :
			return GameContainer.GAME_CONTAINER.Players.get_child(i)
	return null
