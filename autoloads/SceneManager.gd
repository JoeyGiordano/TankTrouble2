extends Node

## Manages scene switching.
## Use Reference for access to preloaded scenes

#There should only ever be one active scene (menu or stage) and it will be the only child of the ActiveSceneHolder node
@onready var ActiveSceneHolder = get_node('/root/GameContainer/ActiveSceneHolder')
#Other scenes can be overlay panels (UI, eg pause menu) and can be put in the OverlayPanels node
@onready var OverlayPanels = get_node('/root/GameContainer/OverlayPanels')


func get_active_scene() -> Node :
	return ActiveSceneHolder.get_child(0)

func switch_active_scene(scene : PackedScene) :
	#replace the scene in the ActiveSceneHolder with a newly instantiated PackedScene scene
	#use Reference to get scenes instead of loading them yourself!
	ActiveSceneHolder.get_child(0).queue_free()
	ActiveSceneHolder.remove_child(ActiveSceneHolder.get_child(0))
	var s = scene.instantiate()
	ActiveSceneHolder.add_child(s)
