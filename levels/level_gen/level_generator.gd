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
@export var scale_ : Vector2i = Vector2i(40,40) #pixel x pixel NOTE: 40 seems to be the default for grid.gd so I'll use that for now
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
	TRIANGLE, #NOTE: requires half the cells to be flipped upside down
	HEXAGON, #NOTE: requires adapting map_bones to some hexagon coords system
	DIAMOND #NOTE: something similar to what hexagon needs, but a bit less work
}

#TODO! (implement this into level gen)
#var tank_spawns : int = PlayerManager.player_count() #NOTE: might need to also account for CPU tanks later!

var map_bones : Array[Array]
# map of the bones as they are created, informs about unvisited/visited neighbors
# NOTE: can also be used for a minimap if you feel so inclined 
# works in [x][y] : +x (left to right), +y (top to down)

var bone_count : int = 0
var active_bones : Array[LevelGenBone] #keeps track of bones with univisited neighbors

func inverse_direction(direction : int) -> int:
	#this varies depending on the number of sides of the tile
	match tile_type:
		TILE_TYPE.SQUARE:
			return (direction+2)%4 #(direction+ceil(sides/2))%sides
	return -1

func direction_to_offset(direction : int) -> Vector2i:
	#again, varies depending on the number of sides of the tile
	match tile_type:
		TILE_TYPE.SQUARE:
			match direction:
				0: #N
					return Vector2i(0,-1)
				1: #E
					return Vector2i(1,0)
				2: #S
					return Vector2i(0,1)
				3: #W
					return Vector2i(-1,0)
	return Vector2i(0,0)

func coords_to_position(coords : Vector2i) -> Vector2i:
	return Vector2i(coords.x*scale_.x,coords.y*scale_.y)

#initializing stage (1)
func _ready(): #NOTE: currently does not wait for anything!
	#initializing the first bone, map_bones, active_bones, wall_template, floor_template
	bone_resource_template.setup(tile_type)
	map_bones.resize(gen_bounds.x)
	for i in map_bones:
		i.resize(gen_bounds.y)
	var origin_bone : LevelGenBone = place_bone(Vector2i(randi_range(0,gen_bounds.x-1),randi_range(0,gen_bounds.y-1)),-1,null) 
	active_bones.append(origin_bone)
	#NOTE: wall template will need some tweaks to accomidate better wall graphics!
	wall_template.scale_ = Vector2(scale_.x*wall_centage,scale_.y)
	wall_template.rotate(PI/2) #starts in north position to make rotation based on direction easier
	#floor_template temp files, will be replaced with something nicer a bit later!
	floor_template.texture = load("uid://dxe5rsvu84bgc")
	floor_template.region_enabled = true
	floor_template.region_rect = Rect2(65,62,2,2)
	floor_template.scale = scale_/2
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
				#TEST reading map_bones
				for i in range(len(map_bones[0])):
					var row : String = ""
					print("===")
					for j in range(len(map_bones)):
						if map_bones[j][i] == null:
							row = row + "[   null    ] | "
						else:
							row = row + str(map_bones[j][i].sides) + " | "
					print(row)
				#end of TEST
				break #THE END (of stage 2)
	level_builder()

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
			"N":
				return active_bones.back()
			"M":
				return active_bones[ceil(active_bones.size()/2.0)]
			"O":
				return active_bones.front()
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
	#probing borders around new bone
	for i in range(new_bone.sides.size()):
		if new_bone.sides[i] == 0:
			var probe_coords : Vector2i = new_bone.coords+direction_to_offset(i)
			if probe_coords.x >= gen_bounds.x or probe_coords.x < 0 or probe_coords.y >= gen_bounds.y or probe_coords.y < 0:
				new_bone.sides[i] = -1 #border
			elif map_bones[probe_coords.x][probe_coords.y] != null:
				new_bone.sides[i] = 1 #there's a cell over there, so wall it off
				map_bones[probe_coords.x][probe_coords.y].sides[inverse_direction(i)] = 1
	return new_bone

#level building stage (3)
func level_builder():
	#walls are placed on borders between tiles
	match tile_type:
		TILE_TYPE.SQUARE:
			#building each square by bottom and right side while dealing with (literal) edge cases
			for i in range(map_bones.size()):
				for j in range(map_bones[i].size()):
					if map_bones[i][j] != null:
						if i == 0:
							place_wall(map_bones[i][j],3) #place left border
						if j == 0:
							place_wall(map_bones[i][j],0) #place top border
						if (map_bones[i][j].sides[1] == 1 or map_bones[i][j].sides[1] == -1):
							place_wall(map_bones[i][j],1) #right wall
						if (map_bones[i][j].sides[2] == 1 or map_bones[i][j].sides[2] == -1):
							place_wall(map_bones[i][j],2) #left wall
						#NOTE: if we implement a tilemap for the floor, we will need to change up this code!
						var floor_sprite = floor_template.duplicate()
						floor_sprite.position = Vector2(coords_to_position(map_bones[i][j].coords))
						floor_holder.add_child(floor_sprite)

func place_wall(bone : LevelGenBone, direction : int):
	match tile_type:
		TILE_TYPE.SQUARE:
			var new_wall : LevelGenWall = wall_template.duplicate()
			new_wall.rotate((PI/2)*(direction%2))
			new_wall.position = Vector2(coords_to_position(bone.coords))
			new_wall.position += Vector2(direction_to_offset(direction)*(scale_/2)) #moving it to border, rather than center
			wall_holder.add_child(new_wall)
