extends Resource
class_name ItemResource

#Info
@export var name : String
@export var description : String

#Functions
@export var func_names : Array[String]

#Stats
@export var forward_speed : float
#@export var forward_speed_multiplier : float
@export var backward_speed : float
@export var rotation_speed : float

#Other
@export var color : Color

#note that when adding a stat, a few lines need to be added in stats.gd and in get_stats() in this class

func get_stats() -> Stats :
	#create a Stats object based on the stats in this resources
	var s = Stats.new()
	s.forward_speed = forward_speed
	s.backward_speed = backward_speed
	s.rotation_speed = rotation_speed
	return s

########################################################################
######   ITEM  SPECIFIC  FUNCTIONS    ########################################

#EXAMPLE
"""
static func amulet_of_empowering_fear(player : Player) :
	if (player.is_scared) : 
		player.stats.top_speed += 10
"""

static func do_nothing(tank : Tank) :
	#for testing
	tank.stats.backward_speed -= 200
	if tank.on_fire : tank.stats.backward_speed = 300
