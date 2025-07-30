extends Node
class_name LevelManager

@onready var spawn_points : Array = $SpawnPoints.get_children()

@export var randomize_spawn_rotation : bool = false

func spawn_players() :
	#spawns players, can be overriden in extended class if more complex behavior is desired
	var num_players = GameManager.GM.player_count
	#check if theres enough spawn points
	if num_players > spawn_points.size() :
		push_error("Not enough spawn points available")
	#spawn players at points randomly
	var p : Array = spawn_points.duplicate()
	p.shuffle() #shuffle the array
	for i in num_players :
		GameManager.GM.player(i+1).respawn(p.get(i).position)
		if randomize_spawn_rotation : GameManager.GM.player(i+1).tank_rigidbody.rotation = randf_range(0,360)
		else : GameManager.GM.player(i+1).tank_rigidbody.rotation = p.get(i).rotation

func tank_died() :
	#called by a tank when it dies
	#calls end of round 2.5 seconds after the most recent tank death
	#can be overriden in extended class if more complex behavior is desired
	var tanks_alive : int = GameManager.GM.alive_players_count()
	if tanks_alive == 1 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		if GameManager.GM.alive_players_count() == 0 : return #if the last surviving player died while the timer was running, let the new timer that was created when it died run out before ending the scene
		GameManager.GM.end_of_round()
	if tanks_alive == 0 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		GameManager.GM.end_of_round()
