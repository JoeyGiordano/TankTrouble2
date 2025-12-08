extends Node2D
class_name ItemSpawner

enum GRID_TYPE {
	NONE, GRID, RAND_GEN
}
@export var grid_type : GRID_TYPE = GRID_TYPE.NONE

@export var spawn_area : Rect2
@export var period_low : float = 3 #seconds
@export var period_high : float = 10
@export var delay : float = 5 #the delay before the first spawn cycle takes place

var item_res : ItemResource = preload("res://game/item/items/item1.tres")#later make this an array and make it variable spawn frequency etc, also consolidate item with loadout upgrade? could also make a random generator
var loadout_item : PackedScene = preload("res://game/item/items/loadout_item.tscn")

var spawning : bool = false
var next_spawn_time : float = 0

func _ready() -> void :
	await get_tree().create_timer(delay).timeout
	calculate_next_spawn_time()
	spawning = true

func _process(_delta) -> void:
	if spawning && is_correct_time() :
		spawn()

func spawn() :
	if grid_type == GRID_TYPE.RAND_GEN :
		rand_gen_spawn()
		return
	var x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
	var y = randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	var pos = Vector2(x, y)
	if grid_type == GRID_TYPE.GRID :
		var g : Grid = get_parent().get_node("Grid")
		pos = g.nearest_square_center(pos, Grid.COORD_TYPE.REAL, Grid.COORD_TYPE.REAL)
	do_spawn(pos)
	#Item.instantiate(item_res, pos)

func rand_gen_spawn() :
	var g : LevelGenerator = get_parent().get_node("LevelGenerator")
	var x = randf_range(0, g.gen_bounds.x)
	var y = randf_range(0, g.gen_bounds.y)
	var pos = g.coords_to_position(Vector2(x,y))
	do_spawn(pos)
	#Item.instantiate(item_res, pos)

var aaa : = ["empty_loadout", "multi_loadout", "landmine_loadout", "nuke_loadout"]
var colors_aaa : = [Color(0.51, 0.0, 0.0, 1.0), Color(0.622, 0.174, 0.83, 1.0),Color(0.194, 0.43, 0.146, 1.0),Color(1.0, 0.483, 0.0, 1.0)]
func do_spawn(pos : Vector2) :
	var i = loadout_item.instantiate()
	var r : ItemResource = i.get_child(3).item_res.duplicate()
	var xr : int = randi_range(0,3)
	r.loadout_name = aaa[xr]
	r.color = colors_aaa[xr]
	i.get_child(3).item_res = r
	Global.Entities.add_child(i)
	i.position = pos

func is_correct_time() -> bool :
	if time() > next_spawn_time :
		calculate_next_spawn_time()
		return true
	return false
	
func calculate_next_spawn_time() :
	next_spawn_time = time() + randf_range(period_low, period_high)

func time() -> float : 
	return float(Time.get_ticks_msec())/1000
