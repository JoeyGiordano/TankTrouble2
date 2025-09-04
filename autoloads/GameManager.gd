extends Node
class_name _GameManager

### AUTOLOAD

### GameManager

## Manages all of the in game things, but continues to exist between games to allow for communication between the menus and the games
## Individual level managers should be used for level specific stuff.

var in_game : bool = false
var score : Vector2 = Vector2.ZERO

signal begin_round
signal end_round

func _ready() -> void:
	PlayerManager.create_players(2) #this is here for now

func game_loop() : #TODO ready_up should send a signal instead of calling this??
	#await players_ready
	create_player_tanks()
	#temp
	PlayerManager.get_associated_tank(0).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color
	var winner = -1
	while true :
		await load_next_level()
		await end_round #TODO renaming
		end_of_round()
		winner = check_for_winner()
		if winner != -1 :
			break
	reset()
	show_victory_screen(winner)

#func players_ready() : #NOTE DELETE
	##called when the players finish readying up in the ready_up shell_scene
	##assume two players for now
	#create_players(2)
	#player(1).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color
	#next_level()
	#pass

### GAME FLOW/LOGIC ###

func create_player_tanks() : #NOTE KEEP
	for p in PlayerManager.players :
		TankManager.create_player_tank(p)

func load_next_level() : #NOTE KEEP
	ShellSceneManager.switch_overlay_panel(Ref.loading) #this loading thing is actually completely unecessary it just looks nice
	ShellSceneManager.switch_active_scene(Ref.game_shell_scene, false)
	LevelLoader.next_level()
	LevelLoader.spawn_players()
	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	#Global.ActiveLevelManager().spawn_players() #NOTE DELETE
	ShellSceneManager.close_overlay_panel() # close loading overlay
	in_game = true # TODO move?
	begin_round.emit() # TODO move?

func tank_died() : # TODO when tank calls this maybe turn into a signal??
	#called by a tank when it dies
	#calls end of round 2.5 seconds after the most recent tank death
	var tanks_alive : int = alive_players_count()
	if tanks_alive == 1 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		if alive_players_count() == 0 : return #if the last surviving player died while the timer was running, let the new timer that was created when it died run out before ending the scene
		end_round.emit() #TODO NEXT signal bus stuff
	if tanks_alive == 0 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		end_round.emit() #TODO NEXT signal bus stuff

func end_of_round() : # NOTE KEEP
	in_game = false #TODO move?
	
	#score the round # NOTE DELETE
	#if !player(1).dead && player(2).dead : 
	#	score.x += 1
	#if !player(2).dead && player(1).dead :
	#	score.y += 1
		
	if !PlayerManager.get_associated_tank(0).dead && PlayerManager.get_associated_tank(1).dead :
		PlayerManager.get_player_profile(0).score += 1
	if !PlayerManager.get_associated_tank(1).dead && PlayerManager.get_associated_tank(0).dead :
		PlayerManager.get_player_profile(1).score += 1
	
	#check for a winner #NOTE DELETE
	#if score.x == 5 :
	#	victory_achieved(1)
	#	return
	#if score.y == 5 :
	#	victory_achieved(2)
	#	return
	
	#if here, there is no winner, go to the next round  # NOTE DELETE
	#next_level()

func check_for_winner() -> int : # NOTE KEEP
	# returns player_id of winning player and ignores ties
	# can make fancier later
	for p in PlayerManager.players :
		if p.score == 5 :
			return p.player_id
	return -1

func reset() :
	PlayerManager.reset_player_scores()
	TankManager.destroy_all_tanks()
	#PlayerManager.delete_all_players() # TODO LATER I don't think this should stay, you should be able to end the game and keep playing with the same custom colors and keybinds
	LevelLoader.remove_level()

func show_victory_screen(player_id) : #NOTE KEEP
	#goes to the victory screen and ensures it displays the right winner, returns to the shell scenes sequence
	ShellSceneManager.switch_active_scene(Ref.victory)
	var label : Label = Global.ActiveShellScene().get_child(1)
	match player_id :
		"draw" : label.text = "Draw"
		1 : label.text = "Player 1 wins"
		0 : label.text = "Player 2 wins"

### PLAYER RESOURCES ###

#func create_players(count : int) : #NOTE DELETE
	##PlayerManager.create_players()
	##destroys existing Players and instantiates [count] Tank scenes childed to Players
	#destroy_all_players()
	##for i in count :
		##Tank.instantiate_tank(Global.Players)
#
#func destroy_all_players() : # NOTE DELETE
	#for j in Global.Players.get_child_count() :
		#Global.Players.get_child(j).queue_free()
#
#func player(id : int) -> Tank : #NOTE DELETE
	##gets player with given id, ids lower than 1 are not players
	#for i in Global.Players.get_child_count() :
		#if Global.Players.get_child(i).id == id :
			#return Global.Players.get_child(i)
	#return null

### MISC RESOURCES ###

func alive_players_count() -> int : #TODO NEXT move somewhere else?
	var players_alive : int = 0 
	for t : Tank in Global.PlayerTanks.get_children() :
		if !t.dead :
			players_alive += 1
	return players_alive
