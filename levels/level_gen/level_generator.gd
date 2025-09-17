extends Node2D
class_name LevelGenerator

## Growing Tree Algorithm Grid-Based Level Generation
## 
## [i]This goes through 3 stages: [/i][br][br]
##
## 1) [b]Initialization [/b][br]
## Where everything begins, based on the many inputs to this script[br][br]
## 2) [b]Skeleton Builder[/b][br]
## Placing the bones of the level and (psuedo) connecting them using the growing tree algorithm[br][br]
## 3) [b]Level Builder[/b][br]
## Building out the level based on the bones generated[br][br]

@export_group("Generation Limits")
@export var gen_bounds : Vector2i = Vector2i(6,6) #cell # width x cell # height
@export_subgroup("Cell Limits")
@export_range(-1,1000,1) var tile_limit : int = 0 #-1 = random, 0 = no limit
@export var random_tile_limit_bounds : Vector2i = Vector2i(1,100)

@export_group("Tiles")
@export var tile_type : TILE_TYPE = TILE_TYPE.SQUARE
#WARNING: scale_ is currently not accodimating x and y not being equal at this time, sorry for the inconvenience!
@export var scale_ : Vector2i = Vector2i(64,64) #pixel x pixel NOTE: 40 seems to be the default for grid.gd so I'll use that for now
@export_range(0.01,1,0.01) var wall_centage : float = 0.05 #percentage of tile_space taken up by wall

# observe decision_maker to see how these are used
# the higher the number the more they're being used
# keeping the total weights to 100 makes it easy to compare different parameter generations
# ex: 30 random (30%) + 40 newest (40%) + 30 middle (30%) = 100% of decision
@export_group("Decision Maker")
@export_range(0,100,1) var random_weight : int = 0
@export_range(0,100,1) var newest_weight : int = 0
@export_range(0,100,1) var middle_weight : int = 0
@export_range(0,100,1) var oldest_weight : int = 0

@export_group("Spawners")
#buffer : no spawners in a area around a spawner, edges: on or as close to the border as possible
@export_enum("Random:0","Random With Buffer:1","Random Edges with Buffer:2","Random Edges:3","Even Edges:4") var spawner_rules : int = 1
@export_range(1,10,1) var spawner_buffers : int = 1 #WARNING: higher buffers can make smaller maps have wonky spawner placement!

#WARNING: smash_random_walls has not been implemented yet, so they do nothing currently
#@export_group("Miscellaneous")
#@export_range(-1,1000,1) var smash_random_walls : int = 0 #-1 = random, 0 = don't kill random walls

@onready var bone_resource_template : LevelGenBone = preload("uid://b2ea07rprulyt")
@onready var wall_template : LevelGenWall = preload("uid://dum6085nqdo78").instantiate()
@onready var floor_template : Sprite2D = Sprite2D.new() #NOTE: super temporary, will be replaced with tilemap later
@onready var bone_holder : Node2D = $Origin/BoneHolder
@onready var wall_holder : Node2D = $Origin/WallHolder
@onready var floor_holder : Node2D = $Origin/FloorHolder
@onready var origin_marker : Marker2D = $Origin #This will be more important once BSP is implemented...

enum TILE_TYPE { #NOTE: Everything but squares are just ideas we can implement (if we want) later
	SQUARE,
	HEXAGON, #pointy side top
	DIAMOND #NOTE: something similar to what hexagon needs, but a bit less work
}

var map_bones : Array[Array]
# map of the bones as they are created, informs about unvisited/visited neighbors
# NOTE: can also be used for a minimap if you feel so inclined 
# works in [x][y] : +x (left to right), +y (top to down)

var bone_count : int = 0
var active_bones : Array[LevelGenBone] #keeps track of bones with univisited neighbors
var tank_spawns : int = PlayerManager.player_count()

#utility
func inverse_direction(direction : int) -> int:
	match tile_type:
		TILE_TYPE.SQUARE:
			return (direction+2)%4 #(direction+ceil(sides/2))%sides
		TILE_TYPE.HEXAGON:
			return (direction+3)%6
	return -1

func direction_to_offset(direction : int) -> Vector2i:
	match tile_type:
		TILE_TYPE.SQUARE:
			match direction:
				0: return Vector2i.UP #N
				1: return Vector2i.RIGHT #E
				2: return Vector2i.DOWN #S
				3: return Vector2i.LEFT #W
		TILE_TYPE.HEXAGON:
			match direction:
				0: return Vector2i(1,-1) #NE
				1: return Vector2i(2,0) #E
				2: return Vector2i(1,1) #SE
				3: return Vector2i(-1,1) #SW
				4: return Vector2i(-2,0) #W
				5: return Vector2i(-1,-1) #NW
	return Vector2i.ZERO

#this only works in the "lines of cells" that each side has extending past it
#4 directions for square, 6 for hexagon
func coords_to_direction(root_coords : Vector2i,target_coords : Vector2i) -> int:
	var offset = (target_coords-root_coords).sign()
	match tile_type:
		TILE_TYPE.SQUARE:
			match offset:
				Vector2i.UP: return 0
				Vector2i.RIGHT: return 1
				Vector2i.DOWN: return 2
				Vector2i.LEFT: return 3
		TILE_TYPE.HEXAGON:
			match offset:
				Vector2i(1,-1): return 0
				Vector2i.RIGHT: return 1
				Vector2i(1,1): return 2
				Vector2i(-1,1): return 3
				Vector2i.LEFT: return 4
				Vector2i(-1,-1): return 5
	return -1

func coords_to_position(coords : Vector2i) -> Vector2i:
	match tile_type:
		TILE_TYPE.SQUARE: 
			return Vector2i(coords.x*scale_.x,coords.y*scale_.y)
		TILE_TYPE.HEXAGON:
			var result = Vector2i(int(coords.x/2.0) *scale_.x,coords.y*int(0.75*scale_.y))
			result += Vector2i(int(scale_.x/2.0)*(coords.x%2),0) #adjusting for odd rows
			return result
	return Vector2i.ZERO

#helps with brevity in code, and verifing the values you're inserting
func get_map_bone(coords : Vector2i) -> LevelGenBone:
	return map_bones[coords.x][coords.y]

#initializing stage (1)
func _ready(): #NOTE: currently does not wait for anything!
		#initializing the first bone, map_bones, active_bones, wall_template, floor_template
	bone_resource_template.setup(tile_type)
	match tile_type:
		TILE_TYPE.SQUARE:
			map_bones.resize(gen_bounds.x)
			for i in map_bones:
				i.resize(gen_bounds.y)
			# wall template setup NOTE: currently temp setup for debug graphics
			wall_template.scale_ = Vector2(scale_.x*wall_centage,scale_.y)
			wall_template.rotate(PI/2) #starts in north rotation
			#floor_template setup NOTE: currently temp setup for debug graphics
			floor_template.texture = load("uid://dxe5rsvu84bgc")
			floor_template.region_enabled = true
			floor_template.region_rect = Rect2(65,62,2,2)
			floor_template.scale = scale_/2
		TILE_TYPE.HEXAGON:
			#hex coords work by doubling rows
			#every even x cell is to the left of an odd x cell
			#odd x cells are in the gap between the four cells (x-1,y-1)(x+1,y-1)(x-1,y+1)(x-1,y-1)
			map_bones.resize(gen_bounds.x*2)
			for i in map_bones:
				i.resize(ceil(gen_bounds.y))
			#wall template setup NOTE: temp
			wall_template.scale_ = Vector2(scale_.x*wall_centage,scale_.y/sqrt(3))
			wall_template.rotate(-PI/3) #starts in northeast rotation
			#floor template setup NOTE: temp
			floor_template.texture = load("uid://bh4tyrtmy7nx7")
			floor_template.scale = scale_/16.0
	var origin_bone : LevelGenBone = place_bone(Vector2i(randi_range(0,map_bones.size()-1),randi_range(0,map_bones[0].size()-1)),-1,null) 
	active_bones.append(origin_bone)
	#starts stage 2
	skeleton_builder()

#skeleton builder stage (2)
func skeleton_builder():
	var tile_limit_flag: bool = true
	if tile_limit == -1: 
		tile_limit = randi_range(random_tile_limit_bounds.x,random_tile_limit_bounds.y)
	if tile_limit == 0: 
		tile_limit_flag = false
	#the main builder loop
	while (true):
		var active_bone : LevelGenBone = decision_maker()
		var direction : int = -1
		#some base randomization for what cell should be added to active_bones
		if active_bone.sides.has(0):
			var possibles : Array[int] = []
			for i in range(active_bone.sides.size()):
				if active_bone.sides[i] == 0:
					possibles.append(i)
			direction = possibles.pick_random()
			place_bone(active_bone.coords+direction_to_offset(direction),direction,active_bone)
		else: #removing the bones with no unvisited neighbors
			active_bones.erase(active_bone)
		if tile_limit_flag:
			if bone_count >= tile_limit or active_bones.is_empty():
				break #THE END (of stage 2)
		else:
			if active_bones.is_empty():
				break #THE END (of stage 2)
	mark_spawners()
	level_builder()
	#TEST
	#debug_display_map_bones()

#WARNING: if the # of tiles is less than tank_spawns, then this will not make a place for all of the tank_spawns
#marks bones to have spawners according to spawner_rules
func mark_spawners():
	var possible_spawns : Array[Vector2i]
	for i in range(map_bones.size()):
		for j in range(map_bones[i].size()):
			if get_map_bone(Vector2i(i,j)) != null:
				possible_spawns.append(Vector2i(i,j))
	#setup for even edges
	var border_spawns : Array[int] = [0,0,0,0]
	for i in range(tank_spawns):
		#Spawner breaks rules to try last attempt to get marked to place
		if possible_spawns.is_empty():
			var failsafe_flag : bool = false
			for j in map_bones:
				for z in j:
					if z != null:
						if z.spawner_flag == false:
							z.spawner_flag = true
							failsafe_flag = true
							break
				if failsafe_flag:
					break
			continue
		#setup for edge rules
		match spawner_rules:
			2,3,4: possible_spawns = possible_spawns.filter(func(c): return (c.x == 0 or c.x == map_bones.size()-1) or (c.y == 0 or c.y == map_bones[0].size()-1))
		#random grab
		var new_spawn_coords : Vector2i = possible_spawns.pick_random()
		possible_spawns.erase(new_spawn_coords)
		get_map_bone(new_spawn_coords).spawner_flag = true
		if spawner_rules == 0: #random doesn't need anything but the basic grab and erase
			continue
		#extra stuff for even edges
		if spawner_rules == 4:
			var border : int = -1
			#corners fall into east/west border for simplicity's sake
			if new_spawn_coords.x == 0: 
				border = 3
			elif new_spawn_coords.x == map_bones.size()-1: 
				border = 1
			elif new_spawn_coords.y == 0: 
				border = 0
			else: 
				border = 2
			border_spawns[border] += 1
			if border_spawns[border] >= ceil(tank_spawns/4.0):
				match border:
					0: possible_spawns.filter(func(c): return not(c.y == 0))
					1: possible_spawns.filter(func(c): return not(c.x == map_bones.size()-1))
					2: possible_spawns.filter(func(c): return not(c.y == map_bones[0].size()-1))
					3: possible_spawns.filter(func(c): return not(c.y == 0))
		#applying buffers
		var buff_out = probe_around_bone(get_map_bone(new_spawn_coords),spawner_buffers,[1])
		for j in buff_out:
			possible_spawns.erase(j[0])

#passes list of coords and met criteria for all bones that fit a value in criteria in check_range
#results is filled from topmost in closest ring to top-leftmost in furthest ring around root_bone
#criteria: -1 = border, 1 = node, 2 = spawner
#check_range: 0 - sides of root, 1 and up - radius of search area NOTE: for some tile_types, 0 and 1 are equivalent!
func probe_around_bone(root_bone : LevelGenBone, check_range : int, criteria : Array[int]) -> Array:
	var results : Array = [] #(Vector2i(x,y),[criteria])
	var probe_list : Array[Vector2i] = []
	if check_range == 0: 
		for i in range(root_bone.sides.size()):
			probe_list.append(root_bone.coords+direction_to_offset(i))
	else:
		match tile_type:
			TILE_TYPE.SQUARE:
				for i in range(1,check_range+1):
					for j in range(root_bone.sides.size()):
						probe_list.append(root_bone.coords+direction_to_offset(j)*i)
						for z in range(1,(i*2)+2):
							#covering every cell in the ring from direction j to direction j+1, exclusive
							probe_list.append(root_bone.coords+(direction_to_offset(j)*i)+direction_to_offset((j+1)%root_bone.sides.size())*(z))
			TILE_TYPE.HEXAGON: #NOTE: not fully tested, don't combine into square just yet
				for i in range(1,check_range+1):
					for j in range(root_bone.sides.size()):
						probe_list.append(root_bone.coords+direction_to_offset(j)*i)
						for z in range(i-1):
							probe_list.append(root_bone.coords+(direction_to_offset(j)*i)+direction_to_offset((j+1)%root_bone.sides.size())*z)
						
	for p in probe_list:
		#checking if probe_coords goes past bounds
		if p.x >= map_bones.size() or p.x < 0 or p.y >= map_bones[0].size() or p.y < 0:
			if criteria.has(-1):
				results.append([p,[-1]])
		elif get_map_bone(p) != null:
			var criteria_met : Array[int] #NOTE: this will be more useful when there's more to probe for
			if criteria.has(1):
				criteria_met.append(1)
			if !criteria_met.is_empty():
				results.append([p,criteria_met])
	return results

func decision_maker() -> LevelGenBone:
	#makes the important decision -- what cell are we building off next?
	var decisions : Array[String]
	for i in range(random_weight):
		decisions.append("R") #random
	for i in range(newest_weight):
		decisions.append("N") #newest
	for i in range(middle_weight):
		decisions.append("M") #middle
	for i in range(oldest_weight):
		decisions.append("O") #oldest
	if !decisions.is_empty():
		var decision : String = decisions.pick_random()
		match decision:
			"N": return active_bones.back()
			"M": return active_bones[int(ceil(active_bones.size()/2.0))-1]
			"O": return active_bones.front()
	return active_bones.pick_random() #random is the default choice

func place_bone(coords : Vector2i, direction : int, branch_bone : LevelGenBone) -> LevelGenBone:
	var new_bone : LevelGenBone = bone_resource_template.duplicate(true)
	new_bone.coords = coords
	active_bones.append(new_bone)
	map_bones[coords.x][coords.y] = new_bone
	#direction of -1 means there is no branch bone (think origin bone)
	if direction != -1:
		new_bone.sides[inverse_direction(direction)] = 2
		branch_bone.sides[direction] = 2
	bone_count += 1
	#maping out around new bone
	var hits : Array = probe_around_bone(new_bone,0,[-1,1])
	for i in hits:
		var dir = coords_to_direction(new_bone.coords,i[0])
		if i[1].has(-1):
			new_bone.sides[dir] = -1 #border
		elif i[1].has(1):
			if get_map_bone(i[0]) == branch_bone:
				continue
			new_bone.sides[dir] = 1 #there's a cell over there, so wall it off
			get_map_bone(i[0]).sides[inverse_direction(dir)] = 1
	return new_bone

#level building stage (3)
func level_builder():
	#walls are placed on borders between tiles
	for i in range(map_bones.size()):
		for j in range(map_bones[i].size()):
			var current_bone = get_map_bone(Vector2i(i,j))
			if current_bone != null:
				match tile_type:
					TILE_TYPE.SQUARE: #building each square by bottom and right side while dealing with (literal) edge cases
						if i == 0:
							place_wall(current_bone,3) #place left border
						if j == 0:
							place_wall(current_bone,0) #place top border
						for z in range(1,3):
							match current_bone.sides[z]: #placing right, bottom walls
								1,-1,0: place_wall(current_bone,z) #placing right, bottom right, bottom left walls
					TILE_TYPE.HEXAGON: #building each hexagon by right, bottom right, and bottom left walls and dealing with borders
						if i <= 1:
							if i == 0:
								place_wall(current_bone,5) #top left border
							place_wall(current_bone,4) #left border
						if j == 0:
							place_wall(current_bone,0) #top right border
							place_wall(current_bone,5) #more top left border
						if i == map_bones.size()-1:
							place_wall(current_bone,0) #more top right border
						for z in range(1,4):
							match current_bone.sides[z]:
								1,-1,0: place_wall(current_bone,z) #placing right, bottom right, bottom left walls
				#NOTE: if we implement a tilemap for the floor, we will need to change up this code!
				var floor_sprite = floor_template.duplicate()
				floor_sprite.position = Vector2(coords_to_position(current_bone.coords))
				floor_holder.add_child(floor_sprite)
				#place spawners
				if current_bone.spawner_flag == true:
					#NOTE: as a workaround to deal with the current player_spawner setup, 
					#I have to store the global_positon by first placing the spawner where the cell center would be,
					#set position to 0,0,
					#and then reparent it to SpawnPoints in the current level,
					#and finally move it to global_position there
					#NOTE: I do not like this :(
					var tank_spawner : Node2D = Node2D.new()
					add_child(tank_spawner)
					tank_spawner.position = Vector2(coords_to_position(get_map_bone(Vector2i(i,j)).coords))
					var g_position = tank_spawner.global_position
					tank_spawner.position = Vector2(0,0)
					tank_spawner.reparent(Global.CurrentLevel().get_node("SpawnPoints"))
					tank_spawner.global_position = g_position
					#TEST: making tank_spawner visible!
					var debug_spawn_sprite : Sprite2D = floor_template.duplicate()
					debug_spawn_sprite.modulate = Color8(0,131,121)
					debug_spawn_sprite.scale = scale_/16 #NOTE: THIS NEEDS TO BE EDITED DEPENDING ON tile_type!
					tank_spawner.add_child(debug_spawn_sprite)

func place_wall(bone : LevelGenBone, direction : int):
	var new_wall : LevelGenWall = wall_template.duplicate()
	match tile_type:
		TILE_TYPE.SQUARE:
			new_wall.rotate((PI/2)*(direction%2))
			new_wall.position = Vector2(coords_to_position(bone.coords)) + Vector2(direction_to_offset(direction)*(scale_/2)) #moving wall to border
		TILE_TYPE.HEXAGON:
			#new_wall.rotate((-(2*PI)/3)*(direction%3))
			new_wall.rotate((PI/3)*direction)
			match direction:
				0,2,3,5:
					new_wall.position = Vector2i((Vector2(coords_to_position(bone.coords))) + Vector2(direction_to_offset(direction).sign())*(Vector2((scale_.x/4.0),(scale_.y*sqrt(3)/4.44))))
				_:
					new_wall.position = Vector2(coords_to_position(bone.coords)) + Vector2(Vector2(direction_to_offset(direction).sign())*(scale_/2.0)) #moving wall to border
	wall_holder.add_child(new_wall)

#TEST debug code functions
func debug_display_map_bones():
	#expect every other cell to be null for hexagons; this is how their coordinate system works
	for i in range(len(map_bones[0])):
		var row : String = ""
		print("===")
		for j in range(len(map_bones)):
			if get_map_bone(Vector2i(j,i)) == null:
				row = row + "[null] | "
			else:
				row = row + str(get_map_bone(Vector2i(j,i)).sides) + " | "
		print(row)

#configuring debug_skip for debug :)
func _process(_delta: float) -> void:
	#reloading the level (and tanks)
	if Input.is_action_just_pressed("DEBUG_SKIP"):
		LevelLoader.switch_level("test_level_gen_level")
		TankManager.call_func_on_all_tanks("despawn")
		TankManager.call_func_on_all_tanks("unlock")
		LevelLoader.spawn_players()

#rotations are incorrect, distance between tiles is incorrect, walls are placed at wrong distance!
#other than that everything works :)
