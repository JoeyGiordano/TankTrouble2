extends Node
class_name _LevelLoader

### AUTOLOAD

### LevelLoader ###
## Loads levels and spawns players.

func remove_level() :
	Utility.remove_scene_in_holder(Global.LevelHolder) # the level manager is on the level node

func next_level() :
	switch_level(_determine_next_level())

func switch_level(level_name : String) :
	_switch_level(Ref.get(level_name))

func _switch_level(new_level : PackedScene) :
	#replace the scene in the LevelHolder with a newly instantiated scene from PackedScene new_level
	#use Reference to get scenes instead of loading them yourself!
	Utility.replace_scene_in_holder(Global.LevelHolder, new_level)

func _determine_next_level() -> String :
	return "custom_level_2" 
