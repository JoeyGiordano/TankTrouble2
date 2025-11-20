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
@export_group("Generation Limits")
## # of cells wide x # of cells tall
@export var gen_bounds : Vector2i = Vector2i(7,7)
@export_subgroup("Pits")
## -1 = random, 0 = no limit, # > 0 = tile_limit
@export_range(-1,1000,1) var level_pits : int = 0
## Spread Evenly = Every region gets an (aproximately) equal number of pits[br]
## Random Spread = Just spread those regions around randomly, hope for the best[br]
## (overloading ignores all above rules)
@export_enum("Spread Evenly : 0","Random Spread : 1") var region_pit_rules : int = 0
@export var random_pits_bounds : Vector2i = Vector2i(1,100)

@export_group("Tiles")
var tile_type : TILE_TYPE = TILE_TYPE.SQUARE #NOTE: change this to export if hexagons are implemented fully
#WARNING: scale_ is currently not accodimating x and y not being equal at this time, sorry for the inconvenience!
## pixel x pixel
@export var scale_ : Vector2i = Vector2i(64,64)
## percentage of tile space taken up by wall
@export_range(0.01,1,0.0001) var wall_centage : float = 0.0625

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

@export_group("Spawners")
## buffer : no spawners in a area around a spawner, edges: on or as close to the border as possible
@export_enum("Random:0","Random With Buffer:1","Random Edges with Buffer:2","Random Edges:3","Even Edges:4") var spawner_rules : int = 1
@export_range(1,10,1) var spawner_buffers : int = 1 #WARNING: higher buffers can make smaller maps have wonky spawner placement!

@export_group("Miscellaneous")
## -1 = random, 0 = don't kill random walls, # > 0 = kill # of random walls
@export_range(-1,1000,1) var smash_random_walls : int = 0
## x = min, y = max
@export var srw_random_limits : Vector2i = Vector2i(1,10)
@export var floor_tileset : TileSet #TODO: make this interface more robust!
#endregion

@onready var floor_layer : TileMapLayer = $FloorLayer
#templates and packedscenes
@onready var bone_resource_template : LevelGenBone = preload("uid://b2ea07rprulyt")
@onready var wall_template : LevelGenWall = preload("uid://dum6085nqdo78").instantiate()
#holders and markers
@onready var wall_holder : Node2D = $Origin/WallHolder

#TEST: debug thing
@onready var debug_square_sprite : Sprite2D = Sprite2D.new()

enum TILE_TYPE {
	SQUARE,
	HEXAGON #pointy side top
	#DIAMOND is planned
}

# stores the locations of all of the bones of the level
# works in [x][y] : +x (left to right), +y (top to down)
var map_bones : Array[Array]
var pits_left : int
var region_manager : RegionManager

var wall_points : Array[Vector2] = [] #holds the midpoints of sides of the tile for wall placement; indexes are direction of side
var player_spawns : int = PlayerManager.player_count()
var player_spawn_points : Array[Vector2i] = [] #stores tilecoords to run spawn_players on

func _ready():
	floor_layer.position = origin_marker.position
	init_generation() #NOTE: remove once you have an outside system calling this

#region utility functions
func inverse_direction(direction : int) -> int:
	match tile_type:
		TILE_TYPE.SQUARE:
			return (direction+2)%4 #(direction+ceil(sides/2))%sides
		TILE_TYPE.HEXAGON:
			return (direction+3)%6
	return -1

## provides map_bones coord offset
func direction_to_offset(direction : int) -> Vector2i:
	match tile_type:
		TILE_TYPE.SQUARE:
			match direction:
				0: return Vector2i.UP #N
				1: return Vector2i.RIGHT #E
				2: return Vector2i.DOWN #S
				3: return Vector2i.LEFT #W
		TILE_TYPE.HEXAGON:
			match direction: #TODO: FIX DIS!
				_:
					pass
	return Vector2i.ZERO

## this only works in the "lines of cells" that each side has extending past it[br]
## 4 directions for square, 6 for hexagon
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
			match offset: #TODO: fix this!
				_:
					pass
	return -1

## relative to floor_layer (gives center of tile) and offset by origin_marker position
func coords_to_position(tile_coords : Vector2i) -> Vector2:
	return origin_marker.position + (floor_layer.map_to_local(tile_coords) * Vector2(ceil(scale_/floor_tileset.tile_size)))

## converts the bone_map coords to tile_map coords based off of origin marker position
func bone_to_tile_coords(bone_coords : Vector2i) -> Vector2i:
	match tile_type:
		TILE_TYPE.HEXAGON: #TODO: fix this up!
			#origin ends up at cell -1,-1 for hexagons
			#hexagon tiles in tileset use an offset x value for odd rows to make the grid, so account for that
			var result = Vector2i(floor_layer.local_to_map(origin_marker.to_local(floor_layer.global_position)))
			result += Vector2i(1,1)
			return result
		_:
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
	match tile_type:
		TILE_TYPE.SQUARE:
			if coords.y <= 0:
				results.append(0)
			if coords.x >= gen_bounds.x-1:
				results.append(1)
			if coords.y >= gen_bounds.y-1:
				results.append(2)
			if coords.x <= 0:
				results.append(3)
		TILE_TYPE.HEXAGON:
			pass
	return results
	

#endregion

#region initializing stage (1) functions
func init_generation():
	#TEST: debug square setup
	debug_square_sprite.texture = load("uid://cm2yn28antisu")
	debug_square_sprite.apply_scale(Vector2(2,2))
	bone_resource_template.setup(tile_type)
	#setting up tilemap layer TODO: needs to be adjusted for more advanced tileset selection
	floor_layer.tile_set = floor_tileset
	floor_layer.scale = scale_/floor_tileset.tile_size
	if level_pits == -1: #random pits
		pits_left = randi_range(random_pits_bounds.x,random_pits_bounds.y)
	else:
		pits_left = level_pits
	match tile_type:
		TILE_TYPE.SQUARE:
			map_bones.resize(gen_bounds.x)
			for i in range(len(map_bones)):
				map_bones[i].resize(gen_bounds.y)
				for j in range(len(map_bones[i])):
					var new_bone = bone_resource_template.duplicate(true)
					new_bone.coords = Vector2i(i,j)
					map_bones[i][j] = new_bone
			# wall template setup NOTE: currently temp setup for debug graphics
			wall_template.scale_ = Vector2(scale_.x*wall_centage,scale_.y)
			wall_template.rotate(deg_to_rad(90)) #starts in north rotation
			wall_points = [Vector2i(0,ceil(-scale_.y/2.0)),Vector2i(ceil(scale_.x/2.0),0),Vector2i(0,ceil(scale_.y/2.0)),Vector2i(ceil(-scale_.x/2.0),0)] #NESW
		TILE_TYPE.HEXAGON:
			#TODO: rework coords
			#wall template setup NOTE: temp
			wall_template.scale_ = Vector2(scale_.x*wall_centage,scale_.y/sqrt(3))
			wall_template.rotate(deg_to_rad(-60)) #starts in northeast rotation
			#storing wall_points
			wall_points.resize(6)
			for i in range(6):
				var mid_point : Vector2 = Vector2(0,0)
				var angle : float = (PI/2) + ((PI/3)*i)
				var next_angle : float = angle + (PI/3)
				#mid points calculated on unit circle and then scaled by radius
				mid_point.x = ((cos(angle))+(cos(next_angle)))/2.0
				mid_point.y = ((sin(angle))+(sin(next_angle)))/2.0
				#radius = half of scale
				#x needs a strange offset, so it gets a funky little math setup
				mid_point *= scale_/2.0
				if i == 1 or i == 4:
					mid_point.x += 0.0671875*scale_.x * mid_point.sign().x
				else:
					mid_point.x += scale_.x/32.0 * mid_point.sign().x
				wall_points[(i+3)%6] = mid_point #making sure the indexes line up with wall direction!
	#stage 2
	region_manager = RegionManager.new(LevelRegion.new(Vector2i.ZERO,gen_bounds),self)
	add_child(region_manager)
	region_manager.generate_regions()
	if smash_random_walls != 0: #NOTE: currently just runs on the domain, but could be made to run on a per-region basis
		random_smash_walls(region_manager.domain,smash_random_walls)
	mark_spawners()
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

#passes list of coords and met criteria for all bones that fit a value in criteria in check_range
#results is filled from topmost in closest ring to top-leftmost in furthest ring around root_bone
#criteria: -2 = pit, -1 = border, 1 = non-empty bone, 2 = spawner
#check_range: 0 - sides of root, 1 and up - radius of search area NOTE: for hexagons, 0 and 1 are equivalent!
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
			TILE_TYPE.HEXAGON: #TODO: CHECK and MAYBE FIX this!
				for i in range(1,check_range+1):
					for j in range(root_bone.sides.size()):
						probe_list.append(root_bone.coords+direction_to_offset(j)*i)
						for z in range(i-1):
							probe_list.append(root_bone.coords+(direction_to_offset(j)*i)+direction_to_offset((j+1)%root_bone.sides.size())*z)
	
	for p in probe_list:
		var bone_p : LevelGenBone = get_map_bone(p)
		if bone_p == null: #borders (every bone is placed at the start, so this shouldn't be a problem to just check for null...)
			if criteria.has(-1):
				results.append([p,[-1]])
		elif bone_p.pit_flag: #pits
			if criteria.has(-2):
				results.append([p,[-2]])
		else:
			var criteria_met : Array[int] #NOTE: this will be more useful when there's more to probe for
			if criteria.has(1):
				if not bone_p.sides.all(func(num): return num != 1 and num != 2):
					criteria_met.append(1)
			if !criteria_met.is_empty():
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
	#walls are placed on borders between tiles
	for i in range(map_bones.size()):
		for j in range(map_bones[i].size()):
			var current_bone = get_map_bone(Vector2i(i,j))
			if current_bone != null:
				var current_tile_coords : Vector2i = bone_to_tile_coords(current_bone.coords)
				if not current_bone.pit_flag:
					place_floor(current_tile_coords)
				match tile_type:
					TILE_TYPE.SQUARE: #building each square by bottom and right side (and borders)
						for z in range(1,3):
							match current_bone.sides[z]:
								1: 
									place_wall(current_tile_coords,z)
								-2:
									if not current_bone.pit_flag:
										place_wall(current_tile_coords,z)
					TILE_TYPE.HEXAGON: #building each hexagon by right, bottom right, and bottom left walls (and borders)
						for z in range(1,4):
							match current_bone.sides[z]:
								1: 
									place_wall(current_tile_coords,z)
								-2:
									if not current_bone.pit_flag:
										place_wall(current_tile_coords,z)
				if not current_bone.pit_flag: #borders
					for z in current_bone.sides.size():
						match current_bone.sides[z]:
							-1,0: place_wall(current_tile_coords,z)
				#mark spawners in list
				if current_bone.spawner_flag == true:
					player_spawn_points.append(current_tile_coords)
					#TEST: making tank_spawner visible!
					display_spawn_point(current_tile_coords)
	spawn_players()

func place_floor(tile_coords : Vector2i):
	#var atlas_coords = Vector2(0,0) #HEXAGON #NOTE: this works for debug, but if you want differing tiles to be placed then you gonna need to randomize this a bit
	var atlas_coords = Vector2(39,29) #SQUARE
	floor_layer.set_cell(tile_coords,0,atlas_coords)

func place_wall(tile_coords : Vector2i, direction : int):
	var new_wall : LevelGenWall = wall_template.duplicate()
	match tile_type: #spinny walls
		TILE_TYPE.SQUARE:
			new_wall.rotate(deg_to_rad(90*(direction%2)))
		TILE_TYPE.HEXAGON:
			new_wall.rotate(deg_to_rad(60*direction))
	new_wall.position = coords_to_position(tile_coords)
	new_wall.position += wall_points[direction]
	wall_holder.add_child(new_wall)
#endregion

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
			row += "[ " + str(map_bones[j][i].coords) + " : " + str(map_bones[j][i].sides) + str(map_bones[j][i].pit_flag) + " ] "
		print(row)
	print()

#configuring debug_skip for debug :)
func _process(_delta: float) -> void:
	#reloading the level (and tanks)
	if Input.is_action_just_pressed("DEBUG_SKIP"):
		LevelLoader.switch_level("test_level_gen_level")
#endregion
