extends Node
class_name StatsHandler

@onready var tank : Tank = get_parent()
@onready var unconditional_stats : Stats = Stats.get_tank_base_stats_copy() #player base stats + unconditional stats from items (updated when a new item is picked up)

func _ready() :
	tank.stats = unconditional_stats.copy()

func _process(_delta):
	handle_process_effects()

func handle_process_effects() :
	#reset the stats to the non-conditional values
	tank.stats = unconditional_stats.copy()
	#add any conditional values
	for item in tank.items.get_children() :
		#calls the item specific functions, passes the player
		for func_name in item.item_res.func_names :
			if func_name == "" : continue
			item.item_res.call(func_name, tank) #this line calls a one of the static functions in the Item_Res class

func handle_pickup(item : Item) :
	#change the unconditional stats (eg if the item has damage +2, the player unconditional_stats damage will increase by 2)
	unconditional_stats.add_stats(item.get_stats())
	#here we could also add something for a special on_pickup() for each item if need be

func handle_drop(item : Item) :
	#if destroy is false, the item should be reparented
	#change the unconditional stats (eg if the item has damage +2, the player unconditional_stats damage will decrease by 2)
	unconditional_stats.subtract_stats(item.get_stats())
	#here we could also add something for a special on_drop() for each item if need be
