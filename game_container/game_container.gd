extends Node
class_name GameContainer

## The root of the game. Manages scene switching.
## Provides access to preset children (GameContainer, ActiveSceneHolder, OverlayPanels) via the GC singleton.

#easy way to access the GameContainer from other nodes
static var GC : GameContainer

#There should only ever be one active scene (menu or stage) and it will be the only child of the ActiveSceneHolder node
@onready var ActiveSceneHolder = $ActiveSceneHolder
#Other scenes can be overlay panels (UI, eg pause menu) and can be put in the OverlayPanels node
@onready var OverlayPanels = $OverlayPanels

#Active Scenes (scenes that might be put in the active scene holder
@onready var startup : PackedScene = preload("res://shell_scenes/startup.tscn")
@onready var main_menu : PackedScene = preload("res://shell_scenes/main_menu.tscn")
@onready var instructions : PackedScene = preload("res://shell_scenes/instructions.tscn")
@onready var credits : PackedScene = preload("res://shell_scenes/credits.tscn")
@onready var ready_up : PackedScene = preload("res://shell_scenes/ready_up/ready_up.tscn")
@onready var victory : PackedScene = preload("res://shell_scenes/victory.tscn")

#don't add levels to the scene dict, instead use switch_to_level()
@onready var scene_dict = {
	"startup" : startup,
	"main_menu" : main_menu,
	"instructions" : instructions,
	"credits" : credits,
	"ready_up" : ready_up,
	"victory" : victory
}

func _init():
	#set up the singleton (not an autoload) (in _init() so that it works when _ready() is called for all other nodes)
	GC = self

func _process(_delta):
	#quit if Q pressed - DEBUG
	if Input.is_action_pressed("DEBUG_QUIT") : get_tree().quit()

### SCENE MANAGEMENT ###

func get_active_scene() -> Node :
	return ActiveSceneHolder.get_child(0)

func switch_to_level(level_name : String) :
	switch_active_scene(load("res://levels/" + level_name + ".tscn"))

func switch_to_scene(scene_name : String) :
	#switch to a scene with the name scene_name
	switch_active_scene(get_scene(scene_name))

func switch_active_scene(scene : PackedScene) :
	#replace the scene in the ActiveSceneHolder with a newly instantiated PackedScene scene
	ActiveSceneHolder.get_child(0).queue_free()
	ActiveSceneHolder.remove_child(ActiveSceneHolder.get_child(0))
	var s = scene.instantiate()
	ActiveSceneHolder.add_child(s)

func get_scene(scene_name : String) -> PackedScene:
	#return the PackedScene with the name scene_name, or return a random stage
	if !scene_dict.has(scene_name) : 
		print("Scene " + scene_name + " is not in scene dict.")
		return main_menu
	return scene_dict[scene_name]
