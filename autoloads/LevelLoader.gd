extends Node
class_name _LevelLoader

### AUTOLOAD

### LevelLoader ###
## Loads levels and spawns players.

func remove_level() :
	destroy_all_entities()
	Utility.remove_scene_in_holder(Global.LevelHolder) # the level manager is on the level node
	
func next_level() :
	switch_level(_determine_next_level())

func switch_level(level_name : String) :
	_switch_level(Ref.get(level_name))

func _switch_level(new_level : PackedScene) :
	#replace the scene in the LevelHolder with a newly instantiated scene from PackedScene new_level
	#use Reference to get scenes instead of loading them yourself!
	destroy_all_entities()
	Utility.replace_scene_in_holder(Global.LevelHolder, new_level)

func _determine_next_level() -> String :
	return "custom_level_1" 

func destroy_all_entities() :
	var x = Global.Entities.get_children()
	for i in range(x.size()-1,-1,-1) :
		Global.Entities.remove_child(x.get(i))
