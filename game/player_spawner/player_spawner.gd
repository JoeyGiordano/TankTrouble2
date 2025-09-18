extends Node2D

func _ready() -> void:
	spawn_players()

func spawn_players() :
	#spawns players, can be overriden in extended class if more complex behavior is desired
	var num_players = PlayerManager.player_count()
	var spawn_points : Array = get_children()
	#check if theres enough spawn points
	assert(num_players <= spawn_points.size(), "Not enough spawn points available in level " + Global.CurrentLevel().name + ". There were " + str(num_players) + " tanks and only " + str(spawn_points.size()) + " spawn points.")
	#spawn players at points randomly
	var p : Array = spawn_points.duplicate()
	p.shuffle() #shuffle the array
	for i in num_players :
		#put at spawn point
		PlayerManager.get_associated_tank(i).respawn(p.get(i).position)
		#randomize rotation
		PlayerManager.get_associated_tank(i).tank_rigidbody.rotation = randf_range(0,360)
		#PlayerManager.get_associated_tank(i).tank_rigidbody.rotation = p.get(i).rotation #could use spawn point rotation instead
