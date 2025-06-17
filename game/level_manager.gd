extends Node
class_name LevelManager

@onready var spawn_points : Array = $SpawnPoints.get_children()

func get_spawn_positions(count : int) -> Array[Vector2] :
	if count > spawn_points.size() :
		push_error("Not enough spawn points available")
	
	var p : Array[Vector2]
	for i in spawn_points.size() : #extract the positions
		p.append(spawn_points.get(i).position)
	#p.shuffle() #shuffle the array
	p.resize(count) #cut off the last elements of the array
	return p
	
	
	
