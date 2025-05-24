extends Node2D
class_name GunHolder

@onready var tank : Tank = get_parent().get_parent()

@onready var do_nothing_gun : PackedScene = preload("res://game/gun/do_nothing_gun.tscn")
@onready var default_gun : PackedScene = preload("res://game/gun/default_gun/default_gun.tscn")

@onready var gun_dict = {
	"do_nothing" : do_nothing_gun,
	"default" : default_gun
}

func switch_to_gun(gun_scene_name : String) :
	#switch to a scene with the name scene_name
	var gun_scene : PackedScene = get_gun_scene(gun_scene_name)
	get_current_gun().queue_free()
	var g : Gun = gun_scene.instantiate()
	add_child(g)
	tank.collision_polygon.set_polygon_by_gun_name(gun_scene_name)

func get_gun_scene(gun_scene_name : String) -> PackedScene:
	#return the PackedScene with the name scene_name, or return a random stage
	if !gun_dict.has(gun_scene_name) : 
		print("Scene " + gun_scene_name + " is not in scene dict.")
		return do_nothing_gun
	return gun_dict[gun_scene_name]

func get_current_gun() -> Gun :
	return get_child(0)
