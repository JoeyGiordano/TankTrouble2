extends Node

#for now, assume two players. This code waits until both of them have pressed their shoot button before starting the game
#this is a bit of a haphazard way to do it, but it'll need a full revamp for multiple players and art. so this works for now
var most_recent_press : int = 0

func _process(delta):
	if Input.is_action_pressed("player1_shoot") :
		if most_recent_press == 2 :
			players_ready()
		most_recent_press = 1
	if Input.is_action_pressed("player2_shoot") :
		if most_recent_press == 1 :
			players_ready()
		most_recent_press = 2
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		players_ready()

func players_ready() :
	GameManager.GAME_MANAGER.player_ready()
