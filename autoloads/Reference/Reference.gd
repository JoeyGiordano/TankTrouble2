extends Node
class_name _Reference

### AUTOLOAD

### Ref ###

## This autoload is keeps all resources together in one place.
## Edit which resources are assigned to the exports in the reference autoload scene (res/autoloads/reference/Reference.tscn).
## The autoload name is Ref not Reference!!!! (For brevity)

## Benefits:
##   1. Easy access
##   2. Reduces number of times each resource is loaded
##   3. Independent of File System oranization (uses exports instead of preload())

## Tip: If you have the string name of a property you can get its value using the get() function.
##   For example, Ref.get("level_0") is the same thing as Ref.level_0

@export_category("Scenes")
@export_group("Shell Scenes")
@export var startup : PackedScene
@export var main_menu : PackedScene
@export var instructions : PackedScene
@export var credits : PackedScene
@export var player_settings : PackedScene
@export var ready_up : PackedScene
@export var loading : PackedScene
@export var game_shell_scene : PackedScene
@export var victory : PackedScene

@export_group("Level Scenes")
@export var test_level_0 : PackedScene
@export var test_level_1 : PackedScene
@export var test_level_2 : PackedScene
@export var test_level_3 : PackedScene
@export var test_level_gen_level : PackedScene
@export var test_level_active_map : PackedScene
@export var custom_level_1 : PackedScene
@export var custom_level_2 : PackedScene

@export_category("Prefabs")
@export_group("Prefabs")
@export var tank_scene : PackedScene
@export var basic_bullet : PackedScene
@export var multi_bullet : PackedScene
@export var land_mine : PackedScene
@export var nuke : PackedScene
@export var item_scene : PackedScene

@export_group("Animations")
@export var explosion_anim : PackedScene


@export_group("Tank Loadouts")
@export var empty_loadout : PackedScene
@export var basic_loadout : PackedScene
@export var multi_loadout : PackedScene
@export var landmine_loadout : PackedScene
@export var nuke_loadout : PackedScene

@export_category("Other")
@export_group("Tank Starting Stats")
@export var base_tank_stats : StatBoost
@export_group("TilesetLib")
@export var tileset_library : TilesetLib

@export_category("Sounds")
@export_group("Tank Loadouts")
@export var basic_shoot_sfx : String = "res://sound/basic_shoot.mp3"
@export var basic_bounce_sfx : String = "res://sound/basic_bounce.mp3"
@export var basic_pop_sfx : String = "res://sound/basic_pop.mp3"
@export var basic_empty_sfx : String = "res://sound/basic_empty.mp3"
@export var landmine_shoot_sfx : String = "res://sound/mine_lay.mp3"
@export var landmine_stepped_on_sfx : String = "res://sound/mine_stepped.mp3"
@export var landmine_explode_sfx : String = "res://sound/mine_explode.mp3"
@export var multibullet_shoot_sfx : String = "res://sound/basic_shoot.mp3"
@export var multibullet_detonate_sfx : String = "res://sound/multi_clank.mp3"
@export var nuke_shoot_sfx : String = "res://sound/nuke_shoot.mp3"
@export var nuke_explode_sfx : String = "res://sound/nuke_explode.mp3"
@export_group("Other")
@export var tank_death_sfx : String = "res://sound/tank_explode.mp3"
@export var item_spawn_sfx : String = "res://sound/item_spawn.mp3"
@export var item_pickup_sfx : String = "res://sound/item_pickup.mp3"
@export var box_explode_sfx : String = "res://sound/exploding_box.mp3"
@export var box_destroy_sfx : String = "res://sound/destructible_box.mp3"
@export var box_hit_sfx : String = "res://sound/crate_hit.mp3"
@export var indestructible_box_hit_sfx : String = "res://sound/indestructible_box_hit.mp3"
