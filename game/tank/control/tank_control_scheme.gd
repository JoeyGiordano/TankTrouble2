class_name TankControlScheme

var tank : Tank
var move : Vector2
var shoot : bool

signal shot

func update_inputs() :
	#calculates current input values and updates them in tank_rigidbody
	#only to be called by Tank during process
	calculate_inputs()
	tank.tank_rigidbody.set_move_input(move)
	tank.tank_rigidbody.set_shoot_input(shoot)

func calculate_inputs() :
	#this method is to be overriden by children of this class
	#for example, player_controls calculates the inputs based on key input
	#the possibility of easily adding other input schemes is for if we want to do some NPC tanks
	pass
