extends Node

## Manages all of the in game things, but continues to exist between games to allow for communication between the menus and the games
## Individual level managers should be used for level specific stuff.

#Important nodes that always exist under the Game Manager, used to hold nodes that are instantiated and uninstantiated in the game (players, bullets, npcs, etc, but not levels structure which is the active scene)
@onready var Players = get_node("/root/GameContainer/GameManager/Players") #The player nodes are instantiated and stored in this node, they can exist even when a menu is on the screen by locking the controls and hiding the player
@onready var Entites = get_node("/root/GameContainer/GameManager/Entities")

#Level manager of the most recently loaded level (does not change when a menu shows, check in_game to see if a level is going)
var level : LevelManager

var in_game : bool = false
var score : Vector2 = Vector2.ZERO
var player_count : int = 2

signal begin_round
signal end_round

func _process(_delta) :
	#if in_game :
	#	$Debug_label.text = player(2).stats.as_string()
	#else : $Debug_label.text = ""
	pass
	
func players_ready() :
	#called when the players finish readying up in the ready_up shell_scene
	#assume two players for now
	SceneManager.switch_active_scene(Reference.test_level_0)
	create_players(2)
	player(1).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color
	next_level()

### GAME FLOW/LOGIC ###

func end_of_round() :
	end_round.emit()
	in_game = false
	
	#score the round
	if !player(1).dead && player(2).dead :
		score.x += 1
	if !player(2).dead && player(1).dead :
		score.y += 1
	
	#check for a winner
	if score.x == 5 :
		victory_achieved(1)
		return
	if score.y == 5 :
		victory_achieved(2)
		return
	
	#if here, there is no winner, go to the next round 
	next_level()

func next_level() :
	SceneManager.switch_active_scene(Reference.loading)
	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	SceneManager.switch_active_scene(Reference.get("test_level_" + str(randi_range(0,2))))
	level = SceneManager.get_active_scene()
	level.spawn_players()
	in_game = true
	begin_round.emit()

func victory_achieved(player_id) :
	#goes to the victory screen and ensures it displays the right winner, returns to the shell scenes sequence
	destroy_all_players()
	SceneManager.switch_active_scene(Reference.victory)
	var label : Label = SceneManager.get_active_scene().get_child(1)
	match player_id :
		"draw" : label.text = "Draw"
		1 : label.text = "Player 1 wins"
		2 : label.text = "Player 2 wins"

### PLAYER RESOURCES ###

func create_players(count : int) :
	#destroys existing Players and instantiates [count] Tank scenes childed to Players
	destroy_all_players()
	for i in count :
		Tank.instantiate_tank(Players, i+1)

func destroy_all_players() :
	for j in Players.get_child_count() :
		Players.get_child(j).queue_free()

func player(id : int) -> Tank :
	#gets player with given id, ids lower than 1 are not players
	for i in Players.get_child_count() :
		if Players.get_child(i).id == id :
			return Players.get_child(i)
	return null

### MISC RESOURCES ###

func alive_players_count() -> int :
	var players_alive : int = 0 
	for t : Tank in Players.get_children() :
		if !t.dead :
			players_alive += 1
	return players_alive
