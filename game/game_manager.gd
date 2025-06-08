extends Node
class_name GameManager

## Manages all of the in game things, but continues to exist between games to allow for communication between the menus and the games
## Provides access to preset children (Players, Bullets, etc) via the GM singleton.
## Individual level managers should be used for level specific stuff.

#easy way to access the GameManager from other nodes
static var GM : GameManager

#Important nodes that always exist under the Game Manager, used to hold nodes that are instantiated and uninstantiated in the game (players, bullets, npcs, etc, but not levels structure which is the active scene)
@onready var Players = $Players #The player nodes are instantiated and stored in this node, they can exist even when a menu is on the screen by locking the controls and hiding the player
@onready var Bullets = $Bullets

var in_game : bool = false
var score : Vector2 = Vector2.ZERO

func _init():
	#set up the singleton (not an autoload) (in _init() so that it works when _ready() is called for all other nodes)
	GM = self

func _process(_delta):
	if in_game :
		$Debug_label.text = player(2).stats.as_string()
	else : $Debug_label.text = ""
	
func players_ready() :
	#called when the players finish readying up in the ready_up shell_scene
	#assume two players for now
	GameContainer.GC.switch_to_level("test_level_0")
	create_players(2)
	in_game = true
	player(1).tank_rigidbody.global_position = Vector2(-450,0)
	player(2).tank_rigidbody.global_position = Vector2(450,0)
	player(1).tank_rigidbody.get_loadout().get_child(0).get_child(1).modulate = Color.BLUE #change one tank color

## END OF ROUND/GAME LOGIC

func tank_died() :
	#makes sure to only call end of round 2.5 seconds after the most recent tank death
	var tanks_alive : int = alive_players_count()
	if tanks_alive == 1 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		if alive_players_count() == 0 : return #if the last surviving player died while the timer was running, let the new timer that was created when it died run out before ending the scene
		end_round()
	if tanks_alive == 0 :
		var timer = get_tree().create_timer(2.5)
		await timer.timeout
		end_round()

func end_round() :
	in_game = false
	for child in Bullets.get_children():
		child.queue_free()
		
	#score the round
	if !player(1).dead && player(2).dead :
		score.x += 1
	if !player(1).dead && player(2).dead :
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
	for tank : Tank in Players.get_children() : tank.end_round()
	GameContainer.GC.switch_to_level("test_level_" + str(randi_range(0,2)))
	for tank : Tank in Players.get_children() :
		tank.begin_round()

func victory_achieved(player_id) :
	destroy_all_players()
	GameContainer.GC.switch_to_scene("victory")
	var label : Label = GameContainer.GC.ActiveSceneHolder.get_child(0).get_child(1)
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
