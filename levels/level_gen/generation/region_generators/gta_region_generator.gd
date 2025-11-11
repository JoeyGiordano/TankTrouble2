extends Node
class_name GTARegionGenerator

### Growing Tree Algorithm Grid-Based Level Generation[br]
## forming bones based on GTA (look it up)
## how the next cell is picked is determined by weights used by decision_maker()

#init variables
var overhead : LevelGenerator
var region : LevelRegion
var region_smash_random_walls : int = 0 #0 for 9none
#internal variables
var region_pits : int = 0
var active_bones : Array[LevelGenBone] = [] #keeps track of bones with univisited neighbors
var connections : Array[Array] = [] #keeps track of connections to ensure they remain so; [bone,sides]

func _init(region_ : LevelRegion, overhead_ : LevelGenerator, region_pits_ : int):
	self.region = region_
	self.overhead = overhead_
	self.region_smash_random_walls = overhead_.smash_random_walls
	self.region_pits = region_pits_
	
func skeleton_builder():
	#storing connections
	_set_connections()
	#placing pits before bones
	if region_pits != 0:
		place_pits()
	#choosing the starting bone of the region
	var region_bones = overhead.region_to_bones(region)
	var region_possibles: Array[LevelGenBone] = []
	for i in region_bones:
		region_possibles.append_array(i.filter(func(bone): return not bone.pit_flag))
	place_bone(region_possibles.pick_random().coords,-1,null)
	#the main builder loop
	while (true):
		var active_bone : LevelGenBone = decision_maker()
		var direction : int = -1
		#some base randomization for what cell should be added to active_bones
		if active_bone.sides.has(0):
			var not_possibles : Array[int] = overhead.region_manager.sides_on_region_border_of(region,active_bone.coords)
			var probe_hits : Array = overhead.probe_around_bone(active_bone,0,[-2]) #checking for pits
			var possibles : Array[int] = []
			for i in range(active_bone.sides.size()):
				if active_bone.sides[i] == 0:
					if not i in not_possibles:
						if not i in probe_hits:
							possibles.append(i)
			if possibles.is_empty():
				active_bones.erase(active_bone)
				if active_bones.is_empty():
					break
				continue
			direction = possibles.pick_random()
			place_bone(active_bone.coords+overhead.direction_to_offset(direction),direction,active_bone)
		else: #removing the bones with no unvisited neighbors
			active_bones.erase(active_bone)
			if active_bones.is_empty():
				break
	#reopening the closed connections between regions
	reopen_connections()


##storing connections
func _set_connections():
	var region_bones : Array[Array] = overhead.region_to_bones(region)
	#checking every border cell for a 2; a connection placed by region_manager
	for i in range(len(region_bones)):
		for j in range(len(region_bones[i])):
			if region_bones[i][j].sides.has(2):
				for z in range(len(region_bones[i][j].sides)):
					if region_bones[i][j].sides[z] == 2:
						connections.append([region_bones[i][j],z])
				region_bones[i][j].sides.fill(0) #closing off connection(s) to allow GTA to work correctly
			#skipping middle section for efficency on top + bottom borders
			if not i == 0 and not i == region_bones.size()-1:
				j = region_bones.size()-1

#placing the pits in the level before we generate everything
func place_pits():
	#turning connections into just the bones
	var connection_bones : Array[LevelGenBone] = []
	for i in connections:
		connection_bones.append(i[0])
	#generating pits
	var pathfinder_map = overhead.get_pathfinder_map(region,false)
	var pits_left = region_pits
	var region_bones : Array[Array] = overhead.region_to_bones(region)
	var inner_flag : bool = false #makes sure the pits loop dosen't last forever
	while (pits_left > 0):
		#we have to loop this setup because the potential pits change whenever a pit is placed
		var possibles : Array[LevelGenBone] = []
		for i in region_bones:
			possibles.append_array(i.filter(func(bone : LevelGenBone): return not bone.pit_flag and not connection_bones.has(bone)))
		if possibles.is_empty():
			break
		while (true): #only breaks when one pit is placed or there's no where to place a pit
			if possibles.is_empty():
				inner_flag = true
				break
			var rolled_bone : LevelGenBone = possibles.pick_random()
			possibles.erase(rolled_bone)
			#we're checking the neighboring bones connection to each other to ensure pits didn't disconnect the level
			var neighbors : Array[LevelGenBone] = []
			pathfinder_map.set_point_disabled(overhead.bone_coords_to_id(region,rolled_bone.coords))
			var region_borders : Array[int] = overhead.region_manager.sides_on_region_border_of(region,rolled_bone.coords)
			for j in range(len(rolled_bone.sides)):
				if not j in region_borders:
					var neighbor = overhead.get_map_bone(rolled_bone.coords + overhead.direction_to_offset(j))
					#no border, no pits
					if not neighbor == null:
						if not neighbor.pit_flag:
							neighbors.append(neighbor)
			var disconnected_flag : bool = false
			for j in range(1,len(neighbors)): #ensuring that the pits placed keep all the bones connected
				if pathfinder_map.get_point_path(overhead.bone_coords_to_id(region,neighbors[j-1].coords),overhead.bone_coords_to_id(region,neighbors[j].coords)).is_empty():
					disconnected_flag = true
					break
			if disconnected_flag: #when a pit would disconnect bones
				pathfinder_map.set_point_disabled(overhead.bone_coords_to_id(region,rolled_bone.coords),false)
				continue
			#finalizing pit placement, only runs if previous check dosen't rerun the loop
			pathfinder_map.remove_point(overhead.bone_coords_to_id(region,rolled_bone.coords))
			place_pit(rolled_bone)
			pits_left -= 1
			break
		if inner_flag:
			break
	#sending stuff to next generator
	if pits_left != 0:
		overhead.region_manager.emit_signal("overloaded_pits",pits_left)

## because bone placement WILL skip over pits :)
func place_pit(bone : LevelGenBone):
	bone.pit_flag = true
	var bones_around : Array = overhead.probe_around_bone(bone,0,[-2,1])
	for i in bones_around:
		var dir = overhead.coords_to_direction(bone.coords,i[0])
		bone.sides[dir] = i[1].get(0) #i[1] is either [-2] (pit) or [1] (non-empty bone)
		overhead.get_map_bone(i[0]).sides[overhead.inverse_direction(dir)] = -2

## "placing" bones ; filling up the currently blank bones with data
func place_bone(coords : Vector2i, direction : int, branch_bone : LevelGenBone) -> LevelGenBone:
	var new_bone : LevelGenBone = overhead.get_map_bone(coords)
	new_bone.coords = coords
	active_bones.append(new_bone)
	#direction of -1 means there is no branch bone (think origin bone)
	if direction != -1:
		new_bone.sides[overhead.inverse_direction(direction)] = 2
		branch_bone.sides[direction] = 2
	#maping out around new bone
	var hits : Array = overhead.probe_around_bone(new_bone,0,[-2,-1,1])
	for i in hits:
		var dir = overhead.coords_to_direction(new_bone.coords,i[0])
		if i[1].has(-1):
			new_bone.sides[dir] = -1 #border
		elif i[1].has(-2):
			new_bone.sides[dir] = -2 #pit
			overhead.get_map_bone(i[0]).sides[overhead.inverse_direction(dir)] = 1
		elif i[1].has(1):
			if not overhead.get_map_bone(i[0]) == branch_bone:
				new_bone.sides[dir] = 1 #there's a cell over there, so wall it off
				overhead.get_map_bone(i[0]).sides[overhead.inverse_direction(dir)] = 1
	return new_bone

## reopening connections because I had to close them during general generation
func reopen_connections():
	for i in connections:
		i[0].sides[i[1]] = 2
		overhead.get_map_bone(i[0].coords+overhead.direction_to_offset(i[1])).sides[overhead.inverse_direction(i[1])] = 2

func decision_maker() -> LevelGenBone:
	#makes the important decision -- what cell are we building off next?
	var decisions : Array[String]
	for i in range(overhead.random_weight):
		decisions.append("R") #random
	for i in range(overhead.newest_weight):
		decisions.append("N") #newest
	for i in range(overhead.middle_weight):
		decisions.append("M") #middle
	for i in range(overhead.oldest_weight):
		decisions.append("O") #oldest
	if !decisions.is_empty():
		var decision : String = decisions.pick_random()
		match decision:
			"N": return active_bones.back()
			"M": return active_bones[int(ceil(active_bones.size()/2.0))-1]
			"O": return active_bones.front()
	return active_bones.pick_random() #random is the default choice
