extends Node
class_name GTARegionGenerator

### Growing Tree Algorithm Grid-Based Level Generation[br]
## forming bones based on GTA (look it up)
## how the next cell is picked is determined by weights used by decision_maker()

#init variables
var overhead : LevelGenerator
var region : LevelRegion
var region_tile_limit : int = 0
var region_smash_random_walls : int = 0 #0 for none
#internal variables
var bone_count : int = 0
var active_bones : Array[LevelGenBone] = [] #keeps track of bones with univisited neighbors
var bone_ages : Array[LevelGenBone] = [] #stores order bones were placed; use this like a stack, index is how many cells were placed after it

func _init(region_ : LevelRegion, overhead_ : LevelGenerator, region_tile_limit_ : int):
	self.region = region_
	self.overhead = overhead_
	self.region_tile_limit = region_tile_limit_
	self.region_smash_random_walls = overhead.smash_random_walls

func skeleton_builder():
	var tile_limit_flag: bool = true
	if region_tile_limit == 0: 
		tile_limit_flag = false
	#choosing the starting bone of the region
	var x = randi_range(region.pos.x,region.pos.x+region.area.x-1)
	var y = randi_range(region.pos.y,region.pos.y+region.area.y-1)
	var origin_bone = place_bone(Vector2i(x,y),-1,null)
	active_bones.append(origin_bone)
	#the main builder loop
	while (true):
		var active_bone : LevelGenBone = decision_maker()
		var direction : int = -1
		#some base randomization for what cell should be added to active_bones
		if active_bone.sides.has(0):
			var possibles : Array[int] = []
			for i in range(active_bone.sides.size()):
				if active_bone.sides[i] == 0:
					match overhead.tile_type:
						LevelGenerator.TILE_TYPE.SQUARE: #don't allow it to exceed region
							if not (active_bone.coords.x <= region.pos.x and i == 3):
								if not (active_bone.coords.y <= region.pos.y and i == 0):
									if not (active_bone.coords.x >= region.pos.x + region.area.x-1 and i == 1):
										if not (active_bone.coords.y >= region.pos.y + region.area.y-1 and i == 2):
											possibles.append(i)
						LevelGenerator.TILE_TYPE.HEXAGON:
							pass #TODO: make this work after hexagons are made working in bsp!
			if possibles.is_empty():
				active_bones.erase(active_bone)
				if tile_limit_flag:
					if bone_count >= region_tile_limit or active_bones.is_empty():
						break # break = the end of bone generation for this region
				else:
					if active_bones.is_empty():
						break
				continue
			direction = possibles.pick_random()
			place_bone(active_bone.coords+overhead.direction_to_offset(direction),direction,active_bone)
		else: #removing the bones with no unvisited neighbors
			active_bones.erase(active_bone)
		if tile_limit_flag:
			if bone_count >= region_tile_limit or active_bones.is_empty():
				break
		else:
			if active_bones.is_empty():
				break

func init_bones():
	pass

func place_bone(coords : Vector2i, direction : int, branch_bone : LevelGenBone) -> LevelGenBone:
	var new_bone : LevelGenBone = overhead.bone_resource_template.duplicate(true)
	bone_ages.push_front(new_bone)
	new_bone.coords = coords
	active_bones.append(new_bone)
	overhead.map_bones[coords.x][coords.y] = new_bone
	#direction of -1 means there is no branch bone (think origin bone)
	if direction != -1:
		new_bone.sides[overhead.inverse_direction(direction)] = 2
		branch_bone.sides[direction] = 2
	bone_count += 1
	#maping out around new bone
	var hits : Array = overhead.probe_around_bone(new_bone,0,[-1,1])
	for i in hits:
		var dir = overhead.coords_to_direction(new_bone.coords,i[0])
		if i[1].has(-1):
			new_bone.sides[dir] = -1 #border
		elif i[1].has(1):
			if overhead.get_map_bone(i[0]) == branch_bone:
				continue
			new_bone.sides[dir] = 1 #there's a cell over there, so wall it off
			overhead.get_map_bone(i[0]).sides[overhead.inverse_direction(dir)] = 1
	return new_bone

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
