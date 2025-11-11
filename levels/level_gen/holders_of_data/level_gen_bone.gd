extends Resource
class_name LevelGenBone

## Holds the bone data for a future section of level[br]

@export var sides : Array[int] # -2 = pit, -1 = border, 0 = unknown, 1 = wall, 2 = opening
var coords : Vector2i = Vector2i(-1,-1) #this will be used for when the bone is randomly picked from active_bones
#extraneous data
var spawner_flag : bool = false #spawn players here
var pit_flag : bool = false #devoid of tile

func setup(tile_type : LevelGenerator.TILE_TYPE):
	#initializing the tile based on tile type
	match tile_type:
		LevelGenerator.TILE_TYPE.SQUARE:
			sides.resize(4) #indexes : 0 - N, 1 - E, 2 - S, 3 - W (NESW)
		LevelGenerator.TILE_TYPE.HEXAGON:
			sides.resize(6) #indexes : 0 - NE, 1 - E, 2 - SE, 3 - SW, 4 - W, 5- NW (NE,E,SE,SW,W,NW)
