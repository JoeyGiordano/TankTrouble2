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
@export var bullet_count : int
@export var bullet_lifetime : float  # in seconds
@export var bullet_speed : float  #in pixels/second

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
	tank.stats.backward_speed -= 20
	if tank.effects_handler.on_fire : tank.stats.backward_speed = 150


######   END BOOST  SPECIFIC  FUNCTIONS    ###################################
########################################################################

# Resource functions

func add(s : StatBoost) :
	# we can possibly use logrithmic adding if we want things to stay above zero (or just use min)
	forward_speed += s.forward_speed
	backward_speed += s.backward_speed
	rotation_speed += s.rotation_speed
	bullet_count += s.bullet_count
	bullet_lifetime += s.bullet_lifetime
	bullet_speed += s.bullet_speed

func subtract(s : StatBoost) :
	forward_speed -= s.forward_speed
	backward_speed -= s.backward_speed
	rotation_speed -= s.rotation_speed
	bullet_count -= s.bullet_count
	bullet_lifetime -= s.bullet_lifetime
	bullet_speed -= s.bullet_speed

func copy() -> StatBoost :
	var s = StatBoost.new()
	s.forward_speed = forward_speed
	s.backward_speed = backward_speed
	s.rotation_speed = rotation_speed
	s.bullet_count = bullet_count
	s.bullet_lifetime = bullet_lifetime
	s.bullet_speed = bullet_speed
	return s

func as_string() -> String :
	var s = ""
	s = s+"Forward Speed: " + str(forward_speed) + "\n"
	s = s+"Backward Speed: " + str(backward_speed) + "\n"
	s = s+"Rotation Speed: " + str(rotation_speed) + "\n"
	s = s+"Bullet Count: " + str(bullet_count) + "\n"
	s = s+"Bullet Lifetime: " + str(bullet_lifetime) + "\n"
	s = s+"Bullet Speed: " + str(bullet_speed) + "\n"
	return s
