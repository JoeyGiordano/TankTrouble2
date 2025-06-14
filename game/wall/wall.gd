@tool
extends Node2D
class_name Wall

## DO NOT EDIT THIS SCRIPT (things will break. I think you can extend from it though without issue)
# A tool script to easily set the posistion of a wall in the Editor

@export var horizontal : bool = false
@export var color : Color = Color.WHITE
@export var length : float = 100.0
@export var width : float = 8.0

@export_category("Grid")
@export var snap_to_grid : bool = true
@export var grid_pos : Vector2i = Vector2i.ZERO
@export var grid_length : int = 1

#children
@onready var col : CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	set_display()

func _process(_delta):
	if Engine.is_editor_hint() :
		if snap_to_grid :
			#snap position to grid
			if grid_length % 2 == 0 :
				grid_pos = Grid.nearest_point(position, Grid.COORD_TYPE.REAL, Grid.COORD_TYPE.GRID)
				position = Grid.grid_to_real(grid_pos)
			elif horizontal :
				grid_pos = Grid.nearest_horizontal_edge_center(position, Grid.COORD_TYPE.REAL, Grid.COORD_TYPE.GRID)
				position = Grid.grid_to_real(grid_pos)
			else :
				grid_pos = Grid.nearest_vertical_edge_center(position, Grid.COORD_TYPE.REAL, Grid.COORD_TYPE.GRID)
				position = Grid.grid_to_real(grid_pos)
			#snap length to grid
			if self in EditorInterface.get_selection().get_selected_nodes() : #make sure node is selected in the tree
				if Input.is_action_just_pressed("ui_up") : grid_length += 1
				if Input.is_action_just_pressed("ui_down") : 
					grid_length -= 1
					if grid_length < 1 : grid_length = 1
			length = grid_length * Grid.scale_ + width
			
		set_display()
		
		#if snap_to_grid :
			#length = grid_length * Grid.scale_ + width
	#
	#if Engine.is_editor_hint() :
		#if self in EditorInterface.get_selection().get_selected_nodes() :
			#
			#var pos_edited_with_keyboard = false
			#if snap_to_grid :
				##respond to key editing
				#if !Input.is_key_pressed(KEY_SHIFT) :
					#if Input.is_action_just_pressed("ui_up") :
						#pos_edited_with_keyboard = true
						#grid_pos.y -= 1
					#if Input.is_action_just_pressed("ui_down") :
						#pos_edited_with_keyboard = true
						#grid_pos.y += 1
					#if Input.is_action_just_pressed("ui_right") :
						#pos_edited_with_keyboard = true
						#grid_pos.x += 1
					#if Input.is_action_just_pressed("ui_left") :
						#pos_edited_with_keyboard = true
						#grid_pos.x -= 1
				#else : 
					#if Input.is_action_just_pressed("ui_up") : grid_length += 1
					#if Input.is_action_just_pressed("ui_down") : 
						#grid_length -= 1
						#if grid_length < 1 : grid_length = 1
					#if Input.is_action_just_pressed("ui_right") : width += 1
					#if Input.is_action_just_pressed("ui_left") : width -= 1
				##respond to mouse editing (where it is minus the difference between where the grid says it should be and where it actually should be with offsets, divided by the grid_size gives the grid_pos)
				#if !pos_edited_with_keyboard :
					#if horizontal :
						#grid_pos.x = round((position.x + grid_offset.x - grid_size/2) / grid_size)
						#grid_pos.y = round((position.y + grid_offset.y) / grid_size)
					#else : 
						#grid_pos.x = round((position.x + grid_offset.x) / grid_size)
						#grid_pos.y = round((position.y + grid_offset.y - grid_size/2) / grid_size)
		#
		set_display()
	#
		if snap_to_grid :
			length = grid_length * Grid.scale_ + width

func set_display() :
	if horizontal :
		col.shape.size = Vector2(length, width)
		sprite.scale = Vector2(length, width)
	else :
		col.shape.size = Vector2(width, length)
		sprite.scale = Vector2(width, length)
	sprite.position = Vector2.ZERO
	sprite.modulate = color
