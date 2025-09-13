extends Resource
class_name LevelGenBone

##Holds the bone data for a future section of level[br]
##Can be used later to hold more advanced data

@export var sides : Array[int] # -1 = border, 0 = unknown, 1 = wall, 2 = opening
var coords : Vector2i #this will be used for when the bone is randomly picked from active_bones

func setup(tile_type : LevelGenerator.TILE_TYPE):
	#initializing the tile based on tile type
	match tile_type:
		LevelGenerator.TILE_TYPE.SQUARE:
			sides.resize(4) #indexes : 0 - N, 1 - E, 2 - S, 3 - W (NESW)
