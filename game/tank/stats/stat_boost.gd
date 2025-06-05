extends Resource
class_name StatBoost

## This script is a resource that holds all of the stats for a tank.
## It acts as a library of static boost specific functions for boosts to use.
## When adding a new boost specific function, put it with all the other ones (between the two comments)
## It also has some helper functions used by stats handler

#Stats
@export var forward_speed : float
#@export var forward_speed_multiplier : float
@export var backward_speed : float
@export var rotation_speed : float

#Functions
@export var func_names : Array[String]

########################################################################
######   BOOST  SPECIFIC  FUNCTIONS    #######################################

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


######   END BOOST  SPECIFIC  FUNCTIONS    ###################################
########################################################################

# Resource functions

func add(s : StatBoost) :
	forward_speed += s.forward_speed
	backward_speed += s.backward_speed
	rotation_speed += s.rotation_speed

func subtract(s : StatBoost) :
	forward_speed -= s.forward_speed
	backward_speed -= s.backward_speed
	rotation_speed -= s.rotation_speed

func copy() -> StatBoost :
	var s = StatBoost.new()
	s.forward_speed = forward_speed
	s.backward_speed = backward_speed
	s.rotation_speed = rotation_speed
	return s

func as_string() -> String :
	var s = ""
	s = s+"Forward Speed: " + str(forward_speed) + "\n"
	s = s+"Backward Speed: " + str(backward_speed) + "\n"
	s = s+"Rotation Speed: " + str(rotation_speed) + "\n"
	return s
