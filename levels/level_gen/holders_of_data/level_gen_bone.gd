extends Resource
class_name LevelGenBone

## Holds the bone data for a future section of level[br]

@export var sides : Array[int] = [0,0,0,0] # -2 = pit, -1 = border, 0 = unknown, 1 = wall, 2 = opening, 3 is box wall
var coords : Vector2i = Vector2i(-1,-1) #this will be used for when the bone is randomly picked from active_bones
#extraneous data
var spawner_flag : bool = false #spawn players here
var pit_flag : bool = false #devoid of tile
var box_flag : bool = false #place a box here on the ground (this is of any type, type is managed by level generator)

func setup():
	sides.resize(4) #indexes : 0 - N, 1 - E, 2 - S, 3 - W (NESW)
