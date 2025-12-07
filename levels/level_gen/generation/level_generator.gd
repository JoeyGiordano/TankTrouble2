extends Node2D
class_name LevelGenerator

### Overhead of level generation; overseer[br]
## also manages general map_bone edits and places the actual level[br][br]
##
##[i]This goes through 3 stages: [/i][br][br]
##
## 1) [b]Initialization [/b][br]
## Where everything begins, based on the many inputs to this script[br][br]
## 2) [b]Skeleton Builder[/b][br]
## Placing the bones of the level and (psuedo) connecting them using the growing tree algorithm[br][br]
## 3) [b]Level Builder[/b][br]
## Building out the level based on the bones generated[br][br]

#region exports
@export_category("Generation Parameters")
@export_group("Dimensions")
## # of cells wide x # of cells tall
@export var gen_bounds : Vector2i = Vector2i(7,7)
#WARNING: scale_ is currently not accodimating x and y not being equal at this time, sorry for the inconvenience!
## pixel x pixel
@export var scale_ : Vector2i = Vector2i(64,64)
## percentage of tile space taken up by wall

@export_group("Pits")
## -1 = random, 0 = no limit, # > 0 = tile_limit
@export_range(-1,1000,1) var level_pits : int = 0
## Spread Evenly = Every region gets an (aproximately) equal number of pits[br]
## Random Spread = Just spread those regions around randomly, hope for the best[br]
## (overloading ignores all above rules)
@export_enum("Spread Evenly : 0","Random Spread : 1") var region_pit_rules : int = 0
@export var random_pits_bounds : Vector2i = Vector2i(1,100)

# observe decision_maker to see how these are used
# the higher the number the more they're being used
@export_group("GTA Level Generation")
@export_subgroup("Decision Maker")
@export_range(0,100,1) var random_weight : int = 0
@export_range(0,100,1) var newest_weight : int = 0
@export_range(0,100,1) var middle_weight : int = 0
@export_range(0,100,1) var oldest_weight : int = 0

@export_group("BSP Region Generation")
## this is the top-left of the level; make sure this is a child of level_generator!
@export var origin_marker : Marker2D
@export_subgroup("Regions")
## how many subregions per region; increasing this exponentially increases the number of regions generated (2^x)
@export var region_divisions : int = 1
##this includes both height and width
@export var region_min_size : int = 1
## Every Region Every Direction = every region has a connection in all 4 cardinal directions[br]
## Every Region Touching = every region connects to all touching regions[br]
## Base Connections = Min connections necessary to have everything connect[br]
@export_enum("Every Region Every Direction : 0","Every Region Touching : 1","Base Connections : 2") var region_connections : int = 0
@export_category("Map Elements")
@export_group("Boxes")
## [d,i,m,e] [br]
## [# of box, random min, random max] [br]
## # = -1 means use random bounds, # = 0 none of that type, # > 0 means that number of boxes[br]
## WARNING: boxes will not be placed if they cannot find a space to put down
@export var box_gen_limits : Array[Vector3i] = [Vector3i(3,1,10),Vector3i(3,1,10),Vector3i(3,1,10),Vector3i(3,1,10)]
## [d,m,e] [br]
## [# of box, random min, random max] [br]
## # = -1 means use random bounds, # = 0 none of that type, # > 0 means that number of boxes
@export var box_health_limits : Array[Vector3i] = [Vector3i(3,1,10),Vector3i(3,1,10),Vector3i(3,1,10)]
##should boxes be allowed to be placed as breakable walls
@export var box_walls : bool = false
##higher numbers means higher chance; 1 is a 1/100 chance
@export_range(1,100,1) var box_wall_chance : int = 50
@export_group("Fields")
@export_subgroup("Placement Parameters")
## [bmod,tmod,mag,grav] [br]
## [# of field, random min, random max] [br]
## # = -1 means use random bounds, # = 0 none of that type, # > 0 means that number of fields[br]
## WARNING: fields will not be placed if they cannot find a space to put down, including a minimum of <= 1 will give you the highest possible chance of placing all fields
@export var field_gen_limits : Array[Vector3i] = [Vector3i(3,1,10),Vector3i(3,1,10),Vector3i(3,1,10),Vector3i(3,1,10)]
##non-square fields
@export var oblong_fields : bool = false
##[bmod,tmod,mag,inv] [br]
##Vector2i(min,max) values (for both x and y dimensions)
@export var field_size_bounds : Array[Vector2] = [Vector2(1,3),Vector2(1,3),Vector2(1,3),Vector2(1,3)]
##the number of "rings" of bones around a field that will not contain another field[br]
##WARNING: high numbers will produce SIGNFICANTLY less fields, also NO NEGATIVES!!!!!!!!
@export_range(0,1000,1) var field_buffer : int = 1
@export_subgroup("Field Mods")
## a negative one value will initiate random, else just uses the provided values (random works for one or both values)
@export var field_bmod_speed : Vector2 = Vector2(2,2)
## upper and lower random bounds for both x and y speed modification Vector2(min,max) [x,y]
@export var field_bmod_speed_r_bounds : Array[Vector2] = [Vector2(1.5,2),Vector2(1.5,2)]
##WARNING: might break down if you try to place a tmod field without giving it a proper stat boost selection to choose from[br]
## each tmod field will be given one of these statboosts at random
@export var field_tmod_statboosts : Array[StatBoost] = []
## -1 = random, everything else does everything else
@export_range(-1,100,1) var field_mag_strength : int = 5
## highly recommend not letting min go to 0 or below[br]
## (min,max), simple random bounds of strength
@export var field_mag_strength_r_bounds : Vector2i = Vector2i(1,11)
## -1 = random, 0 = off, 1 = on
@export_range(-1,1,1) var field_mag_clockwise : int = 1

#manages tileset stuff
@export_group("Floor")
@export_enum("debug","road") var floor_tileset_id : String = "debug"
## #/100 chance for alternate tile to be used in tileset
@export_range(0,100,1) var alternate_chance : int = 50

@export_category("Miscellaneous")
@export_group("Smash Random Walls")
## -1 = random, 0 = don't kill random walls, # > 0 = kill # of random walls
@export_range(-1,1000,1) var smash_random_walls : int = 0
## x = min, y = max
@export var srw_random_limits : Vector2i = Vector2i(1,10)
@export_group("Player Spawners")
## buffer : no spawners in a area around a spawner, edges: on or as close to the border as possible
@export_enum("Random:0","Random With Buffer:1","Random Edges with Buffer:2","Random Edges:3","Even Edges:4") var spawner_rules : int = 1
@export_range(1,10,1) var spawner_buffers : int = 1 #WARNING: higher buffers can make smaller maps have wonky spawner placement!

#endregion

@onready var floor_layer : TileMapLayer = $FloorLayer
#templates and packedscenes
@onready var bone_resource_template : LevelGenBone = preload("uid://b2ea07rprulyt")
@onready var wall_template : LevelGenWall = preload("uid://dum6085nqdo78").instantiate()
@onready var pillar_template : LevelGenPillar = preload("uid://xanig5lgg8wt").instantiate()
#holders and markers
@onready var wall_holder : Node2D = $Holders/WallHolder
@onready var box_holder : Node2D = $Holders/BoxHolder
@onready var field_holder : Node2D = $Holders/FieldHolder
#map elements
@onready var box_d : PackedScene = preload("uid://bx2nhx7cbggc4")
@onready var box_i : PackedScene = preload("uid://kgb8qiwyx3h5")
@onready var box_m : PackedScene = preload("uid://bco7bn3j6pl3n")
@onready var box_e : PackedScene = preload("uid://dhnun2qb7oy3g")
@onready var field_bmod : PackedScene = preload("uid://b2vd12pjydjhl")
@onready var field_tmod : PackedScene = preload("uid://c6wb8oosdthco")
@onready var field_mag : PackedScene = preload("uid://dx0nr0e7wnvtg")
@onready var field_inv : PackedScene = preload("uid://bdbhw1olqqxyt")

#TEST: debug thing
@onready var debug_square_sprite : Sprite2D = Sprite2D.new()

# stores the locations of all of the bones of the level
# works in [x][y] : +x (left to right), +y (top to down)
var map_bones : Array[Array]
var pits_left : int = 0
var level_boxes : int = 0
var region_manager : RegionManager
var floor_tileset : TileSet

var wall_points : Array[Vector2] = [] #holds the midpoints of sides of the tile for wall placement; indexes are direction of side
var player_spawns : int = PlayerManager.player_count()
var player_spawn_points : Array[Vector2i] = [] #stores tilecoords to run spawn_players on

func _ready():
	init_generation() #NOTE: remove once you have an outside system calling this

#region utility functions
func inverse_direction(direction : int) -> int:
	return (direction+2)%4 #(direction+ceil(sides/2))%sides

## provides map_bones coord offset
func direction_to_offset(direction : int) -> Vector2i:
	match direction:
		0: return Vector2i.UP #N
		1: return Vector2i.RIGHT #E
		2: return Vector2i.DOWN #S
		3: return Vector2i.LEFT #W
	return Vector2i.ZERO

## this only works in the "lines of cells" that each side has extending past it[br]
## 4 directions for square, 6 for hexagon
func coords_to_direction(root_coords : Vector2i,target_coords : Vector2i) -> int:
	var offset = (target_coords-root_coords).sign()
	match offset:
		Vector2i.UP: return 0
		Vector2i.RIGHT: return 1
		Vector2i.DOWN: return 2
		Vector2i.LEFT: return 3
	return -1

## relative to floor_layer (gives center of tile) and offset by origin_marker position
func coords_to_position(tile_coords : Vector2i) -> Vector2:
	return origin_marker.position + (floor_layer.map_to_local(tile_coords))

## converts the bone_map coords to tile_map coords based off of origin marker position
func bone_to_tile_coords(bone_coords : Vector2i) -> Vector2i:
	return Vector2i(floor_layer.local_to_map(origin_marker.to_local(floor_layer.global_position)) + bone_coords)

## helps with brevity in code, and verifing the values you're inserting[br]
## returns null if no such bone exists with provided coords
func get_map_bone(coords : Vector2i) -> LevelGenBone:
	if coords.x < 0 or coords.x >= gen_bounds.x:
		return null
	var x = map_bones.get(coords.x)
	if x != null:
		if coords.y < 0 or coords.y >= gen_bounds.y:
			return null
		return x.get(coords.y)
	return null

## region pos to position; pos is the top_left corner of every tile in a region
func pos_to_position(pos : Vector2i) -> Vector2:
	return origin_marker.position + Vector2(pos*scale_)

## returns the portion of map_bones corresponding to the region provided
func region_to_bones(region : LevelRegion) -> Array[Array]: #TODO: make this work with hexagons
	var region_bones : Array[Array] = []
	for i in range(region.pos.x,region.pos.x+region.area.x):
		region_bones.append(map_bones[i].slice(region.pos.y,region.pos.y+region.area.y))
	return region_bones

## for pathfinder map of region tile id to be converted to bone_coords
func id_to_bone_coords(region : LevelRegion, id : int):
	var result = Vector2i.ZERO
	result.x = id % region.area.x
	result.y = floori(id / float(region.area.y))
	result += region.pos
	return result

## for bone_coords to tile id in pathfinder map of region
func bone_coords_to_id(region : LevelRegion, coords : Vector2i):
	coords -= region.pos
	return (coords.y * region.area.x) + coords.x

## returns a map of tile and their connections for pathfinding (and other) purposes in region [br]
## connections are from center of a tile to neighbor center[br]
## tile ids = (y coord * region.area.x) + x coord[br]
## check_walls is only false for pit placement, so you should pretty much ignore it
func get_pathfinder_map(region : LevelRegion, check_walls : bool = true) -> AStar2D:
	var astar_map = AStar2D.new()
	var region_bones = region_to_bones(region)
	#plotting points
	for i in range(len(region_bones)):
		for j in range(len(region_bones[i])):
			var id : int = (j * region.area.x) + i
			astar_map.add_point(id,coords_to_position(region_bones[i][j].coords))
	#connecting points
	for i in range(len(region_bones)):
		for j in range(len(region_bones[i])):
			var id_a : int = (j * region.area.x) + i
			var bone : LevelGenBone = region_bones[i][j]
			#not creating points on level border AND region border
			var border_sides : Array[int] = sides_on_level_border_of(bone.coords)
			border_sides.append_array(region_manager.sides_on_region_border_of(region,bone.coords))
			for z in range(len(bone.sides)):
				if not z in border_sides:
					if bone.sides[z] == 2 or not check_walls:
						var n_coords = bone.coords + direction_to_offset(z)
						if not get_map_bone(n_coords).pit_flag:
							astar_map.connect_points(id_a,bone_coords_to_id(region,n_coords))
	return astar_map

func sides_on_level_border_of(coords : Vector2i) -> Array[int]:
	var results : Array[int] = []
	if coords.y <= 0:
		results.append(0)
	if coords.x >= gen_bounds.x-1:
		results.append(1)
	if coords.y >= gen_bounds.y-1:
		results.append(2)
	if coords.x <= 0:
		results.append(3)
	return results

##instantiates a box based on level generator parameters and provided box type
func instance_box(box_type : int) -> Node2D:
	var new_box : Node2D
	match box_type:
		0:
			new_box = box_d.instantiate()
			if box_health_limits[0].x == -1:
				new_box.health = randi_range(box_health_limits[0].y,box_health_limits[0].z)
			else:
				new_box.health = box_health_limits[0].x
		1:
			new_box = box_i.instantiate()
		2:
			new_box = box_m.instantiate()
			if box_health_limits[1].x == -1:
				new_box.health = randi_range(box_health_limits[1].y,box_health_limits[1].z)
			else:
				new_box.health = box_health_limits[1].x
		3:
			new_box = box_e.instantiate()
			if box_health_limits[2].x == -1:
				new_box.health = randi_range(box_health_limits[2].y,box_health_limits[2].z)
			else:
				new_box.health = box_health_limits[2].x
	return new_box

##handles creating fields for the level, and uses level gen parameters for wanted randomness
func instance_field(field_type : int, dimensions : Array[float]) -> Node2D:
	var new_field : Node2D
	#for special scale needs
	var scale_edit : Vector2
	match field_type:
		0: #bmod
			new_field = field_bmod.instantiate()
			#giving bullet speed modification
			for i in 2:
				if field_bmod_speed[i] == -1:
					new_field.speed_mod[i] = randf_range(field_bmod_speed_r_bounds[i].x,field_bmod_speed_r_bounds[i].y)
				else:
					new_field.speed_mod[i] = field_bmod_speed[i]
		1: #tmod
			new_field = field_tmod.instantiate()
			#giving a random statboost from the selection provided
			new_field.boost = field_tmod_statboosts.pick_random()
		2: #mag
			new_field = field_mag.instantiate()
			#mag strength
			if field_mag_strength == -1:
				new_field.magnetic_strength = randi_range(field_mag_strength_r_bounds.x,field_mag_strength_r_bounds.y)
			else:
				new_field.magnetic_strength = field_mag_strength
			#mag spin
			if field_mag_clockwise == -1:
				if randi_range(0,1) == 0:
					new_field.clockwise_rotation = false
				else:
					new_field.clockwise_rotation = true
			else:
				if field_mag_clockwise == 0:
					new_field.clockwise_rotation = false
				else:
					new_field.clockwise_rotation = true
			scale_edit = Vector2(20,20) #WARNING: if you change field size in any way, you will need to edit these
		3: #inv
			new_field = field_inv.instantiate()
			scale_edit = Vector2(20,20) #WARNING: if you change field size in any way, you will need to edit these
	if oblong_fields:
		new_field.scale.x = (dimensions[0]*scale_.x)/scale_edit.x
		new_field.scale.y = (dimensions[1]*scale_.y)/scale_edit.y
	else:
		new_field.scale.x = (dimensions[0]*scale_.x)/scale_edit.x
		new_field.scale.y = (dimensions[0]*scale_.y)/scale_edit.y
	return new_field
#endregion

#region initializing stage (1) functions
func init_generation():
	#TEST: debug square setup
	debug_square_sprite.texture = load("uid://cm2yn28antisu")
	debug_square_sprite.apply_scale(Vector2(2,2))
	
	#floor init
	#TEST: making debug easier on the eyes
	#floor_layer.modulate = Color(0.468, 0.468, 0.468, 1.0)
	floor_tileset = Ref.tileset_library.lock_and_load_tileset(floor_tileset_id)
	floor_layer.tile_set = floor_tileset
	floor_layer.position = origin_marker.position
	
	#pit init
	if level_pits == -1: #random pits
		pits_left = randi_range(random_pits_bounds.x,random_pits_bounds.y)
	else:
		pits_left = level_pits
	
	#box init
	for i in box_gen_limits:
		if i.x == -1:
			i.x = randi_range(i.y,i.z)
		level_boxes += i.x
	
	#bone init
	bone_resource_template.setup()
	map_bones.resize(gen_bounds.x)
	for i in range(len(map_bones)):
		map_bones[i].resize(gen_bounds.y)
		for j in range(len(map_bones[i])):
			var new_bone = bone_resource_template.duplicate(true)
			new_bone.coords = Vector2i(i,j)
			map_bones[i][j] = new_bone
	
	wall_template.rotate(deg_to_rad(90)) #starts in north rotation
	wall_points = [Vector2i(0,ceil(-scale_.y/2.0)),Vector2i(ceil(scale_.x/2.0),0),Vector2i(0,ceil(scale_.y/2.0)),Vector2i(ceil(-scale_.x/2.0),0)] #NESW
	
	#stage 2
	region_manager = RegionManager.new(LevelRegion.new(Vector2i.ZERO,gen_bounds),self)
	add_child(region_manager)
	region_manager.generate_regions()
	if smash_random_walls != 0:
		random_smash_walls(region_manager.domain,smash_random_walls)
	mark_spawners()
	mark_boxes()
	#stage 3 start
	level_builder()
#endregion

#region skeleton builder stage (2) functions
## marks bones to have spawners according to spawner_rules [br]
## WARNING: if the # of tiles is less than player_spawns, then this will not make a place for all of the player spawns
func mark_spawners():
	var possible_spawns : Array[Vector2i]
	for i in range(map_bones.size()):
		for j in range(map_bones[i].size()):
			if get_map_bone(Vector2i(i,j)).pit_flag != true:
				possible_spawns.append(Vector2i(i,j))
	#setup for even edges
	var border_spawns : Array[int] = [0,0,0,0]
	for i in range(player_spawns):
		#Spawner breaks rules to try last attempt to get marked to place
		if possible_spawns.is_empty():
			var failsafe_flag : bool = false
			for j in map_bones:
				for z in j:
					if z.pit_flag != true:
						if z.spawner_flag == false:
							z.spawner_flag = true
							failsafe_flag = true
							break
				if failsafe_flag:
					break
			continue
		#setup for edge rules
		match spawner_rules:
			2,3,4: possible_spawns = possible_spawns.filter(func(c): return get_map_bone(c) != null)
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
			if border_spawns[border] >= ceil(player_spawns/4.0):
				match border:
					0: possible_spawns.filter(func(c): return not(c.y == 0))
					1: possible_spawns.filter(func(c): return not(c.x == map_bones.size()-1))
					2: possible_spawns.filter(func(c): return not(c.y == map_bones[0].size()-1))
					3: possible_spawns.filter(func(c): return not(c.y == 0))
		#applying buffers
		var buff_out = probe_around_bone(get_map_bone(new_spawn_coords),spawner_buffers,[1])
		for j in buff_out:
			possible_spawns.erase(j[0])

#handles marking bones for future box placement
func mark_boxes():
	for i in level_boxes:
		var possibles : Array[LevelGenBone] = []
		for j in map_bones: #no pits or player spawns should have a box_flag toggled
			possibles.append_array(j.filter(func(bone : LevelGenBone): return not bone.pit_flag and not bone.spawner_flag))
		if not box_walls: #just need to place a box on the floor
			possibles = possibles.filter(func(bone : LevelGenBone): return not bone.box_flag)
			if possibles.is_empty(): #no boxes can be placed
				return
			var rolled_bone : LevelGenBone = possibles.pick_random()
			rolled_bone.box_flag = true
		else: #rolling for chance to place wall, if chance is possible on the selected bone
			possibles = possibles.filter(func(bone : LevelGenBone): return not bone.box_flag or bone.sides.has(1))
			if possibles.is_empty(): #no boxes can be placed
				return
			while (true): #keep going until something is actually placed
				var rolled_bone : LevelGenBone = possibles.pick_random()
				if rolled_bone.sides.has(1):
					if randi_range(1,100) <= box_wall_chance: #rolling box wall
						var possible_sides : Array[int] = []
						for j in range(len(rolled_bone.sides)):
							if rolled_bone.sides[j] == 1:
								possible_sides.append(j)
						var rolled_side : int = possible_sides.pick_random()
						rolled_bone.sides[rolled_side] = 3
						get_map_bone(rolled_bone.coords+direction_to_offset(rolled_side)).sides[inverse_direction(rolled_side)] = 3
						break
				if not rolled_bone.box_flag: #defaulting to ground box, if possible
					rolled_bone.box_flag = true
					break

##passes list of coords and met criteria for all bones that fit a value in criteria in check_range[br]
##results is filled from topmost in closest ring to top-leftmost in furthest ring around root_bone[br]
##criteria: -2 = pit, -1 = border, 1 = non-empty bone, 2 = player spawner[br]
##check_range: 0 - sides of root, 1 and up - radius of search area NOTE: for hexagons, 0 and 1 are equivalent!
func probe_around_bone(root_bone : LevelGenBone, check_range : int, criteria : Array[int]) -> Array:
	var results : Array = [] #(Vector2i(x,y),[criteria])
	var probe_list : Array[Vector2i] = []
	
	#finding things
	if check_range == 0: 
		for i in range(root_bone.sides.size()):
			probe_list.append(root_bone.coords+direction_to_offset(i))
	else:
		for i in range(1,check_range+1):
			for j in range(root_bone.sides.size()):
				probe_list.append(root_bone.coords+(direction_to_offset(j)*i))
				for z in range(1,i+1):
					#heading clockwise from the middle of side j
					probe_list.append(root_bone.coords+(direction_to_offset(j)*i)+(direction_to_offset((j+1)%root_bone.sides.size())*(z)))
				for z in range(1,i):
					#heading counterclockwise from the middle of side j
					probe_list.append(root_bone.coords+(direction_to_offset(j)*i)+(direction_to_offset((inverse_direction(j+1))%root_bone.sides.size())*(z)))
	
	#reading things
	for p in probe_list:
		var bone_p : LevelGenBone = get_map_bone(p)
		if bone_p == null: #borders (every bone is placed at the start, so this shouldn't be a problem to just check for null...)
			if criteria.has(-1):
				results.append([p,[-1]])
		elif bone_p.pit_flag: #pits
			if criteria.has(-2):
				results.append([p,[-2]])
		else:
			var criteria_met : Array[int] = []
			if criteria.has(1):
				if not bone_p.sides.all(func(num): return num != 1 and num != 2):
					criteria_met.append(1)
			if criteria.has(2):
				if bone_p.spawner_flag:
					criteria_met.append(2)
			if not criteria_met.is_empty():
				results.append([p,criteria_met])
	return results

func random_smash_walls(region : LevelRegion, walls_to_smash : int):
	if walls_to_smash == -1:
		walls_to_smash = randi_range(srw_random_limits.x,srw_random_limits.y)
	else:
		walls_to_smash = walls_to_smash
	var wall_havers : Array = [] #list of bones with walls
	for i in region_to_bones(region): #grabbing every bone with a smashable wall (no borders)
		wall_havers += i.filter(func(obj : LevelGenBone): return obj != null and obj.sides.has(1) and not obj.pit_flag)
		#smash walls loop
	for i in range(walls_to_smash):
		if wall_havers.is_empty():
			break
		var target_bone : LevelGenBone = wall_havers.pick_random()
		var target_walls : Array[int] = []
		for j in range(target_bone.sides.size()): #grabs a wall
			if target_bone.sides[j] == 1:
				target_walls.append(j)
		var target = target_walls.pick_random()
		target_bone.sides[target] = 2 #hits target_bone wall
		var victim_bone = get_map_bone(target_bone.coords + direction_to_offset(target))
		victim_bone.sides[inverse_direction(target)] = 2 #hits other side of wall's bone's wall
		#clearing out the dead
		if not target_bone.sides.has(1):
			wall_havers.erase(target_bone)
		if not victim_bone.sides.has(1):
			wall_havers.erase(victim_bone)
#endregion

#region level building stage (3) functions
func level_builder():
	#box type picker setup
	var box_type_pool : Array[int] = []
	for i in range(len(box_gen_limits)):
		for j in box_gen_limits[i].x:
			box_type_pool.append(i)
	
	#building loop
	for i in range(map_bones.size()):
		for j in range(map_bones[i].size()):
			var current_bone = get_map_bone(Vector2i(i,j))
			if current_bone != null:
				var current_tile_coords : Vector2i = bone_to_tile_coords(current_bone.coords)
				
				#scanning for wall placement needs
				var neighbor_walls_exist : Array[bool] = [false,false,false,false]
				for z in range(4):
					if current_bone.sides[z] != -1: #not border
						var neighbor_bone : LevelGenBone = get_map_bone(current_bone.coords + direction_to_offset(z))
						match z:
							0: #N
								if neighbor_bone.sides[1] != 2:
									neighbor_walls_exist[1] = true
								if neighbor_bone.sides[3] != 2:
									neighbor_walls_exist[0] = true
							1: #E
								if neighbor_bone.sides[0] != 2:
									neighbor_walls_exist[1] = true
								if neighbor_bone.sides[2] != 2:
									neighbor_walls_exist[2] = true
							2: #S
								if neighbor_bone.sides[1] != 2:
									neighbor_walls_exist[2] = true
								if neighbor_bone.sides[3] != 2:
									neighbor_walls_exist[3] = true
							3: #W
								if neighbor_bone.sides[0] != 2:
									neighbor_walls_exist[0] = true
								if neighbor_bone.sides[2] != 2:
									neighbor_walls_exist[3] = true
				
				if not current_bone.pit_flag:
					place_floor(current_tile_coords,current_bone)
					#building each square by bottom and right side (and borders)
					for z in range(1,3):
						match current_bone.sides[z]:
							1:
								place_wall(current_tile_coords,z)
							-2:
								if not current_bone.pit_flag:
									place_wall(current_tile_coords,z)
							3:
								#place_box_wall(current_tile_coords,z,box_type_pool.pop_at(randi_range(0,box_type_pool.size()-1)))
								place_box_wall(current_tile_coords,z,randi_range(0,3))
								
					#borders
					for z in current_bone.sides.size():
						match current_bone.sides[z]:
							-1,0: place_wall(current_tile_coords,z)
					#pillars
					if current_bone.sides[1] != 2 or current_bone.sides[2] != 2 or neighbor_walls_exist[2]:
						place_pillar(current_tile_coords,2)
					
					#pillars on edges
					if current_bone.sides[2] == -1 and current_bone.sides[3] == -1:
						place_pillar(current_tile_coords,3)
					if current_bone.sides[3] == -1:
						place_pillar(current_tile_coords,0)
					if current_bone.sides[0] == -1:
						place_pillar(current_tile_coords,1)
					
				else: #something something fixing code something something
					for z in range(1,3):
						match current_bone.sides[z]:
							1: place_wall(current_tile_coords,z)
					
					#pillar placement
					if current_bone.sides[3] == -1 and current_bone.sides[0] == 1:
						place_pillar(current_tile_coords,0)
					if current_bone.sides[0] == -1 and current_bone.sides[1] == 1:
						place_pillar(current_tile_coords,1)
					#normal pillars
					if current_bone.sides[1] != -2 or current_bone.sides[2] != -2 or neighbor_walls_exist[2]:
						place_pillar(current_tile_coords,2)
				
				#mark spawners in list
				if current_bone.spawner_flag == true:
					player_spawn_points.append(current_tile_coords)
				#box placement
				if current_bone.box_flag == true:
					#place_box(current_tile_coords,box_type_pool.pop_at(randi_range(0,box_type_pool.size()-1)))
					place_box(current_tile_coords,randi_range(0,3))
	place_fields()
	spawn_players()

func place_floor(tile_coords : Vector2i, bone : LevelGenBone):
	var prim_bits : int = 0
	var second_bits : int = 0
	var atlas_coords = 0
	var neighbor_walls_exist : Array[bool] = [false,false,false,false] #NW,NE,SE,SW
	#reading neighbor walls
	for i in 4:
		if bone.sides[i] != -1: #not border
			var neighbor_bone : LevelGenBone = get_map_bone(bone.coords + direction_to_offset(i))
			#print(neighbor_bone)
			match i:
				0: #N
					if neighbor_bone.sides[1] != 2:
						neighbor_walls_exist[1] = true
					if neighbor_bone.sides[3] != 2:
						neighbor_walls_exist[0] = true
				1: #E
					if neighbor_bone.sides[0] != 2:
						neighbor_walls_exist[1] = true
					if neighbor_bone.sides[2] != 2:
						neighbor_walls_exist[2] = true
				2: #S
					if neighbor_bone.sides[1] != 2:
						neighbor_walls_exist[2] = true
					if neighbor_bone.sides[3] != 2:
						neighbor_walls_exist[3] = true
				3: #W
					if neighbor_bone.sides[0] != 2:
						neighbor_walls_exist[0] = true
					if neighbor_bone.sides[2] != 2:
						neighbor_walls_exist[3] = true
	#reading side walls, and results from checking neighbors
	for i in 4:
		if bone.sides[i] != 2: #not open
			prim_bits += int(pow(2,(i*2)+1))
			second_bits += int(pow(2,i))
		if neighbor_walls_exist[i]:
			prim_bits += int(pow(2,i*2))
	atlas_coords = Ref.tileset_library.grab_atlas(prim_bits,second_bits,floor_tileset_id,alternate_chance)
	floor_layer.set_cell(tile_coords,Ref.tileset_library.grab_atlas_id(floor_tileset_id),atlas_coords)

## walls are placed on borders between tiles
func place_wall(tile_coords : Vector2i, direction : int):
	var new_wall : LevelGenWall = wall_template.duplicate()
	new_wall.rotate(deg_to_rad(90*(direction%2)))
	new_wall.position = coords_to_position(tile_coords)
	new_wall.position += wall_points[direction]
	wall_holder.add_child(new_wall)

func place_pillar(tile_coords : Vector2i, corner : int):
	var new_pillar : LevelGenPillar = pillar_template.duplicate()
	new_pillar.position = coords_to_position(tile_coords)
	new_pillar.position += wall_points[corner]
	match corner:
		0:
			new_pillar.position.x -= (scale_.x/2.0)
		1:
			new_pillar.position.y -= (scale_.y/2.0)
		2:
			new_pillar.position.x += (scale_.x/2.0)
		3:
			new_pillar.position.y += (scale_.y/2.0)
	wall_holder.add_child(new_pillar)

## placing a line of boxes as a pseduo wall
func place_box_wall(tile_coords : Vector2i, direction : int, box_type : int):
	var splits : int = 0 #number of boxes placed, math number
	var new_box : Node2D = instance_box(box_type)
	var box_list : Array[Node2D] = [new_box]
	var wall_offset : Vector2 = Vector2.ZERO #just used to move positions over, makes the math easier
	var wall_length : Vector2 = Vector2.ZERO #used to place the boxes along the wall
	var box_half : Vector2 = Vector2.ZERO #literally just half the box size
	var buffer : Vector2 = Vector2.ZERO #buffer between corners of tiles
	
	#silly little maths
	match direction:
		0,2:
			buffer = Vector2(6,0)
			splits = int((scale_.x-buffer.x)/((new_box.get_child(0).get_child(0).shape.get_rect().size.x)))
			wall_offset = Vector2(int(scale_.x/2.0),0)
			wall_length = Vector2(scale_.x,0)-buffer
			box_half = Vector2((new_box.get_child(0).get_child(0).shape.get_rect().size.x/2.0)+1,0)
		1,3:
			buffer = Vector2(0,6)
			splits = int((scale_.y-buffer.y)/((new_box.get_child(0).get_child(0).shape.get_rect().size.y)))
			wall_offset = Vector2(0,int(scale_.y/2.0))
			wall_length = Vector2(0,scale_.y)-buffer
			box_half = Vector2(0,(new_box.get_child(0).get_child(0).shape.get_rect().size.y/2.0)+1)
	
	#actually placing things
	for i in splits-1:
		box_list.append(instance_box(box_type))
	for i in range(len(box_list)): #setting box positions
		var pos = coords_to_position(tile_coords) #to the tile
		pos += wall_points[direction] #to the wall center
		pos -= wall_offset #back a bit
		pos += (box_half + (buffer/2.0)) + (i * ((wall_length/splits))) #forward without overlapping boxes
		box_list.get(i).position = pos
		box_holder.add_child(box_list.get(i))

func place_box(tile_coords : Vector2i, box_type : int):
	var new_box : Node2D = instance_box(box_type)
	new_box.position = coords_to_position(tile_coords)
	#moving it about randomly in the tile (without overlapping with walls)
	var place_offset_range : Vector4 = Vector4(-scale_.x/2.0,scale_.x/2.0,-scale_.y/2.0,scale_.y/2.0) #x lower, x higher, y lower, y higher (bounds)
	place_offset_range[0] += ceili(3 + new_box.get_child(0).get_child(0).shape.get_rect().size.x/2.0)
	place_offset_range[1] -= ceili(3 + new_box.get_child(0).get_child(0).shape.get_rect().size.x/2.0)
	place_offset_range[2] += ceili(3 + new_box.get_child(0).get_child(0).shape.get_rect().size.y/2.0)
	place_offset_range[3] -= ceili(3 + new_box.get_child(0).get_child(0).shape.get_rect().size.y/2.0)
	new_box.position += Vector2(randi_range(int(place_offset_range[0]),int(place_offset_range[1])),randi_range(int(place_offset_range[2]),int(place_offset_range[3])))
	box_holder.add_child(new_box)
#endregion

##places fields
func place_fields():
	#list of field types setup
	var field_type_pool : Array[int] = []
	for i in range(len(field_gen_limits)):
		if field_gen_limits[i].x == -1:
			for j in randi_range(field_gen_limits[i].y,field_gen_limits[i].z):
				field_type_pool.append(i)
		else:
			for j in field_gen_limits[i].x:
				field_type_pool.append(i)
	#preparing the "map" for where to put field (centers)
	var open_map : Array[LevelGenBone] = []
	for i in map_bones:
		open_map.append_array(i.filter(func(bone : LevelGenBone): return not bone.spawner_flag))
	#grabbing a field_type and placing it according to parameters
	for i in range(len(field_type_pool)):
		var temp_map : Array[LevelGenBone] = open_map.filter(func(bone : LevelGenBone): return not bone.pit_flag) #no center on pit
		var field_type = field_type_pool.pop_at(randi_range(0,field_type_pool.size()-1))
		#searching for appropriate bone to place the field in
		while not temp_map.is_empty():
			var rolled_bone : LevelGenBone = temp_map.pop_at(randi_range(0,temp_map.size()-1))
			#checking for player spawners and bypassing border at min distance around rolled bone
			var open_flag : bool = true
			if field_size_bounds[field_type].x > 1: #there's no need to probe if the field is within a bone
				if (probe_around_bone(rolled_bone,int(field_size_bounds[field_type].x/2.0),[-1,2]).is_empty()):
					#checking for overlapping fields in min size
					for j in probe_around_bone(rolled_bone,int(field_size_bounds[field_type].x/2.0),[-2,1]):
						if get_map_bone(j[0]) not in open_map:
							open_flag = false #failed
							break
				else: #failed
					open_flag = false
			if open_flag:
				#checking for largest possible placement bounded by min and max of field type
				var probe_flag : bool
				var probe_range : int = maxi(1,int(field_size_bounds[field_type].y/2.0))
				while (probe_range >= maxi(1,int(field_size_bounds[field_type].x/2.0))):
					probe_flag = true
					#checking for player spawners around current max
					if probe_around_bone(rolled_bone,probe_range,[-1,2]).is_empty():
						#checking for overlapping fields within current max
						for j in probe_around_bone(rolled_bone,probe_range,[-2,1]):
							if get_map_bone(j[0]) not in open_map:
								probe_flag = false
								break
						if probe_flag: #all checks have been cleared successfully
							break
					probe_range -= 1
				#making and placing the field
				var dimensions : Array[float] = [1.0,0.0]
				if probe_flag: #if probe found space availiable larger than min
					dimensions[0] = randf_range(field_size_bounds[field_type].x,minf(field_size_bounds[field_type].y,(probe_range*2)+1))
					if oblong_fields:
						dimensions[1] = (randf_range(field_size_bounds[field_type].x,minf(field_size_bounds[field_type].y,(probe_range*2)+1)))
				else: #else, default to pre-approved min size
					var p : int = int(field_size_bounds[field_type].x)
					if (field_size_bounds[field_type].x/2.0)-int(field_size_bounds[field_type].x/2.0) == 0.5: #because 0.5 can't round to 0
						dimensions[0] = field_size_bounds[field_type].x
						if oblong_fields:
							dimensions[1] = field_size_bounds[field_type].x
					else:
						if p % 2 == 0:
							p += 1
						else:
							p += 2
						dimensions[0] = randf_range(field_size_bounds[field_type].x,p)
						if oblong_fields:
							dimensions[1] = randf_range(field_size_bounds[field_type].x,p)
				var new_field : Node2D = instance_field(field_type,dimensions)
				new_field.position = coords_to_position(bone_to_tile_coords(rolled_bone.coords))
				field_holder.add_child(new_field)
				#marking on the open_map that a field is here
				open_map.erase(rolled_bone)
				if max(dimensions[0],dimensions[1]) > 1: #no need to probe if the field is within a tile
					var last_probe : Array = []
					if max(dimensions[0]/2.0,dimensions[1]/2.0)-(maxi(int(dimensions[0]/2.0),int(dimensions[1]/2.0))) == 0.5: #truncating on borders, because round can't bring 0.5 to 0
						last_probe = probe_around_bone(rolled_bone,(maxi(1,maxi(int(dimensions[0]/2.0),int(dimensions[1]/2.0)))+field_buffer),[-2,1])
					else: #literally everything but the borders of "rings"
						last_probe = probe_around_bone(rolled_bone,(maxi(1,maxi(roundi(dimensions[0]/2.0),roundi(dimensions[1]/2.0)))+field_buffer),[-2,1])
					if oblong_fields:
						#not including the bones that aren't actually being covered by the new field
						var x_check : bool = dimensions[0] < dimensions[1]
						for j in last_probe:
							if x_check:
								if j[0].x < rolled_bone.coords.x - (int(dimensions[0]/2.0)+field_buffer) or j[0].x > rolled_bone.coords.x + (int(dimensions[0]/2.0)+field_buffer):
									last_probe.erase(j)
							else:
								if j[0].y < rolled_bone.coords.y - (int(dimensions[1]/2.0)+field_buffer) or j[0].y > rolled_bone.coords.y + (int(dimensions[1]/2.0)+field_buffer):
									last_probe.erase(j)
					for j in last_probe:
						open_map.erase(get_map_bone(j[0]))
				else: #applying field buffer on fields of 1 by 1
					var last_probe : Array = probe_around_bone(rolled_bone,field_buffer,[-2,1])
					for j in last_probe:
						open_map.erase(get_map_bone(j[0]))
				break #stops the search, we got what we need

#copied code from player_spawner, with some minor modifications
func spawn_players():
	assert(player_spawns <= player_spawn_points.size(), "Not enough spawn points available in level " + Global.CurrentLevel().name + ". There were " + str(player_spawns) + " tanks and only " + str(player_spawn_points.size()) + " spawn points.")
	var p : Array = player_spawn_points.duplicate()
	p.shuffle()
	for i in player_spawns : 
		PlayerManager.get_associated_tank(i).respawn(coords_to_position(p[i]))
		PlayerManager.get_associated_tank(i).tank_rigidbody.rotation = randf_range(0,360)

#region debug functions
func display_spawn_point(tile_coords : Vector2i):
	var debug_spawn_sprite : Sprite2D = debug_square_sprite.duplicate()
	debug_spawn_sprite.modulate = Color8(0,131,121)
	debug_spawn_sprite.apply_scale(Vector2(8,8))
	add_child(debug_spawn_sprite)
	debug_spawn_sprite.position = coords_to_position(tile_coords)

#displaying map bones and whatever else you might need
func debug_print_map_bones():
	print("=== DISPLAY_MAP_BONES: ===")
	print()
	for i in gen_bounds.y:
		var row = " "
		for j in gen_bounds.x:
			row += "[ " + str(map_bones[j][i].coords) + " : " + str(map_bones[j][i].position) + " ] "
		print(row)
	print()

#configuring debug_skip for debug :)
func _process(_delta: float) -> void:
	#reloading the level (and tanks)
	if Input.is_action_just_pressed("DEBUG_SKIP"):
		LevelLoader.switch_level("test_level_gen_level")
#endregion
