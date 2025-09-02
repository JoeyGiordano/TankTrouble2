extends Node
class_name _GameManager

### AUTOLOAD

### GameManager

## Manages all of the in game things, but continues to exist between games to allow for communication between the menus and the games
## Individual level managers should be used for level specific stuff.

var in_game : bool = false
var score : Vector2 = Vector2.ZERO
var player_count : int = 2

signal begin_round
signal end_round

## temp func for now, for serious implementation later
func game_loop() :
	#await players_ready
	#before_first_level_stuff()
	#for ...
	#	start_level()
	#	await all_tanks_died
	#	clear_level()
	#	end level()
	#show_victory_screen()
	# or something like that
	pass

func players_ready() :
	#called when the players finish readying up in the ready_up shell_scene
	#assume two players for now
	ShellSceneManager.switch_active_scene(Ref.test_level_0)
	create_players(2)
	player(1).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color
	next_level()

### GAME FLOW/LOGIC ###

func end_of_round() :
	print("here")
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
	ShellSceneManager.switch_overlay_panel(Ref.loading)
	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	ShellSceneManager.switch_active_scene(Ref.game_shell_scene)
	LevelLoader.next_level()
	Global.ActiveLevelManager().spawn_players()
	ShellSceneManager.close_overlay_panel() # close loading overlay
	in_game = true
	begin_round.emit()

func victory_achieved(player_id) :
	#goes to the victory screen and ensures it displays the right winner, returns to the shell scenes sequence
	destroy_all_players()
	LevelLoader.remove_level()
	ShellSceneManager.switch_active_scene(Ref.victory)
	var label : Label = Global.ActiveShellScene().get_child(1)
	match player_id :
		"draw" : label.text = "Draw"
		1 : label.text = "Player 1 wins"
		2 : label.text = "Player 2 wins"

### PLAYER RESOURCES ###

func create_players(count : int) :
	#destroys existing Players and instantiates [count] Tank scenes childed to Players
	destroy_all_players()
	for i in count :
		Tank.instantiate_tank(Global.Players, i+1)

func destroy_all_players() :
	for j in Global.Players.get_child_count() :
		Global.Players.get_child(j).queue_free()

func player(id : int) -> Tank :
	#gets player with given id, ids lower than 1 are not players
	for i in Global.Players.get_child_count() :
		if Global.Players.get_child(i).id == id :
			return Global.Players.get_child(i)
	return null

### MISC RESOURCES ###

func alive_players_count() -> int :
	var players_alive : int = 0 
	for t : Tank in Global.Players.get_children() :
		if !t.dead :
			players_alive += 1
	return players_alive
