extends Node
class_name GameContainer

#easy way to access the GameContainer from other nodes
static var GAME_CONTAINER : GameContainer

#There should only ever be one active scene (menu or stage) and it will be the only child of the ActiveSceneHolder node
@onready var ActiveSceneHolder = $ActiveSceneHolder
#Other scenes can be overlay panels (UI, eg pause menu) and can be put in the OverlayPanels node
@onready var OverlayPanels = $OverlayPanels
#The player nodes are instantiated in the Players node, they can be hidden and frozen when necessary (if the player nodes do not need to persist this structure is not necessary)
@onready var Players = $Players

#Other Scenes
@onready var tank_scene : PackedScene = preload("res://tank/tank.tscn")

#Active Scenes (scenes that might be put in the active scene holder
@onready var startup : PackedScene = preload("res://scenes/startup.tscn")
@onready var main_menu : PackedScene = preload("res://scenes/main_menu.tscn")
@onready var instructions : PackedScene = preload("res://scenes/instructions.tscn")
@onready var credits : PackedScene = preload("res://scenes/credits.tscn")
@onready var ready_up : PackedScene = preload("res://scenes/ready_up/ready_up.tscn")
@onready var game : PackedScene = preload("res://scenes/game.tscn")
@onready var victory : PackedScene = preload("res://scenes/victory.tscn")

@onready var scene_dict = {
	"startup" : startup,
	"main_menu" : main_menu,
	"instructions" : instructions,
	"credits" : credits,
	"ready_up" : ready_up,
	"game" : game,
	"victory" : victory	
}

func _ready():
	#set up the singleton (not an autoload)
	GAME_CONTAINER = self

func _process(delta):
	#quit if Q pressed - DEBUG
	if Input.is_action_pressed("DEBUG_QUIT") : get_tree().quit()

### SCENE MANAGEMENT ###

func switch_to_scene(scene_name : String) :
	#switch to a scene with the name scene_name
	switch_active_scene(get_scene(scene_name))

func switch_active_scene(scene : PackedScene) :
	#replace the scene in the ActiveSceneHolder with a newly instantiated PackedScene scene
	ActiveSceneHolder.get_child(0).queue_free()
	var s = scene.instantiate()
	ActiveSceneHolder.add_child(s)

func get_scene(scene_name : String) -> PackedScene:
	#return the PackedScene with the name scene_name, or return a random stage
	#frist if statement is old, I left it in so we know where to put it later if needed
	#if scene_name == "random_stage" :
		#return get_random_stage()
	if !scene_dict.has(scene_name) : 
		print("Scene " + scene_name + " is not in scene dict.")
		return main_menu
	return scene_dict[scene_name]

### PLAYER MANAGEMENT ###

func create_players(count : int) :
	#destroys existing Players and instantiates [count] Tank scenes childed to Players
	destroy_all_players()
	for i in count :
		var s = Tank.instantiate_tank(true, i+1)
		Players.add_child(s)

func destroy_all_players() :
	for j in Players.get_child_count() :
		Players.get_child(j).queue_free()
