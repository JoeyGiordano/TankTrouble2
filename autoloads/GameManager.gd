extends Node
class_name _GameManager

### AUTOLOAD

### GameManager
## Manages the flow of the game (game_loop()). Mostly calls methods in other autoloads and sends/receives signals.

var in_game : bool = false

func _ready() -> void:
	PlayerManager.create_players(2) # TODO this is here for now, will be moved to a add players shell scene later

func game_loop() : #TODO ready_up should send a signal instead of calling this??
	#await players_ready
	create_player_tanks()
	#temp
	PlayerManager.get_associated_tank(0).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color
	var winner = -1
	while true :
		await load_next_level()
		await SignalBus.end_round #TODO renaming
		end_of_round()
		winner = check_for_winner()
		if winner != -1 :
			break
	reset()
	show_victory_screen(winner)

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
	ShellSceneManager.close_overlay_panel() # close loading overlay
	in_game = true # TODO move?
	SignalBus.begin_round.emit()

func tank_died() : # TODO when tank calls this maybe turn into a signal??
	#called by a tank when it dies
	#calls end of round 2.5 seconds after the most recent tank death
	var tanks_alive : int = GameInfo.alive_players_count()
	if tanks_alive == 1 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		if GameInfo.alive_players_count() == 0 : return #if the last surviving player died while the timer was running, let the new timer that was created when it died run out before ending the scene
		SignalBus.end_round.emit()
	if tanks_alive == 0 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		SignalBus.end_round.emit()

func end_of_round() : # NOTE KEEP
	in_game = false #TODO move?
	
	if !PlayerManager.get_associated_tank(0).dead && PlayerManager.get_associated_tank(1).dead :
		PlayerManager.get_player_profile(0).score += 1
	if !PlayerManager.get_associated_tank(1).dead && PlayerManager.get_associated_tank(0).dead :
		PlayerManager.get_player_profile(1).score += 1

func check_for_winner() -> int : # NOTE KEEP
	# returns player_id of winning player (score>5) and ignores ties
	# can make fancier later
	for p in PlayerManager.players :
		if p.score == 5 :
			return p.player_id
	return -1

func reset() :
	TankManager.destroy_all_tanks()
	#PlayerManager.delete_all_players() # TODO LATER I don't think this should stay, you should be able to end the game and keep playing with the same custom colors and keybinds
	PlayerManager.reset_player_scores() # subbing above with this for now. Note that this is paired with the todo in ready on PlayerManager.create_players(2)
	LevelLoader.remove_level()

func show_victory_screen(player_id) : #NOTE KEEP
	#goes to the victory screen and ensures it displays the right winner, returns to the shell scenes sequence
	ShellSceneManager.switch_active_scene(Ref.victory)
	var label : Label = Global.CurrentShellScene().get_child(1)
	match player_id :
		"draw" : label.text = "Draw"
		1 : label.text = "Player 1 wins"
		0 : label.text = "Player 2 wins"

### MISC RESOURCES ###
