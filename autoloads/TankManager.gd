extends Node
class_name _TankManager

### AUTOLOAD

### TankManager ###


var next_id : int = 0

## Get

func get_tank(tank_id : int) -> Tank :
	for t : Tank in Global.PlayerTanks.get_children() :
		if t.id == tank_id :
			return t
	for t : Tank in Global.NpcTanks.get_children() :
		if t.id == tank_id :
			return t
	return null

## Create

func create_player_tank(p : PlayerProfile) -> Tank :
	var t : Tank = _create_tank(Global.PlayerTanks, p)
	p.associate(t.id)
	print("p" + str(t.id))
	return t

func create_npc_tank(p : TankProfile, associate : bool = false) :
	var t : Tank = _create_tank(Global.NpcTanks, p)
	if associate :
		p.associate(t.id)
	print("n" + str(t.id))
	return t

func _create_tank(parent : Node, profile : TankProfile = TankProfile.new()) -> Tank :
	var t : Tank = Ref.tank_scene.instantiate()
	# NOTE _init() is called during the execution of the previous line
	#set id
	t.id = next_id
	next_id += 1
	#set profile
	t.profile = profile
	#add the new tank to the scene tree
	parent.add_child(t)
	# NOTE _ready() is called during the execution of the previous line (first on all the children of the tank, then on the tank)
	return t

# Destroy

func destroy_tank(tank_id : int) :
	var t : Tank = get_tank(tank_id)
	_destroy_tank(t)

func destroy_all_tanks() :
	for i in range(Global.PlayerTanks.get_children().size() - 1, -1, -1) :
		_destroy_tank(Global.PlayerTanks.get_children()[i])

func _destroy_tank(t : Tank) :
	t.profile.dissociate()
	t.queue_free()

##### NEED TO CHECK TO SEE IF THIS IS A REAL PATTERN, COULD BE USEFUL (like you could pass a tank method to this and it would call it on all tanks)
func test1() :
	test("die")

func test(method_name : String) :
	var t : Tank
	t.call(method_name)
