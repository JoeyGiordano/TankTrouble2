extends Node

### Reference ###

## This autoload is used to keep all bulky exports together in one place.
## Edit which resources are assigned to the exports in the reference autoload scene (res/autoloads/reference/Reference.tscn).

## Benefits:
##   1. Easy access
##   2. Reduces number of times each resource is loaded
##   3. Independent of File System oranization (uses exports instead of preload())

## Tip: If you have the string name of a property you can get its value using the get() function.
##   For example, button_scene_switch exports a string, scene_name, the name of the scene to be switched to.
##   It then calls Reference.get(scene_name) to get the associated PackedScene to be passed to the SceneSwitcher. 


@export_category("Scenes")

@export_group("Shell Scenes")
@export var startup : PackedScene
@export var main_menu : PackedScene
@export var instructions : PackedScene
@export var credits : PackedScene
@export var ready_up : PackedScene
@export var loading : PackedScene
@export var victory : PackedScene

@export_group("Level Scenes")
@export var test_level_0 : PackedScene
@export var test_level_1 : PackedScene
@export var test_level_2 : PackedScene

@export_group("Prefabs")
@export var basic_bullet : PackedScene

@export_category("Other")
