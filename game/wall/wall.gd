@tool
extends Node2D
class_name Wall

@export var snap : bool = true

@export var horizontal : bool = false
@export var length : float = 100.0
@export var width : float = 8.0
@export var color : Color = Color.WHITE

#Grid Settings
static var grid_size_ : float = 0
static var grid_offset_ : Vector2 = Vector2.ZERO
@export var grid_size : float = 40
@export var grid_offset : Vector2 = Vector2(20,20)
@export var grid_pos : Vector2i = Vector2i.ZERO
@export var grid_length : int = 1

#children
@onready var col : CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	set_display()

func _process(_delta):
	if Engine.is_editor_hint() :
		if self in EditorInterface.get_selection().get_selected_nodes() :
			#recieve and share changes to grid size and offset
			grid_size_ = grid_size
			grid_offset_ = grid_offset
			
			var pos_edited_with_keyboard = false
			if snap :
				#respond to key editing
				if !Input.is_key_pressed(KEY_SHIFT) :
					if Input.is_action_just_pressed("ui_up") :
						pos_edited_with_keyboard = true
						grid_pos.y -= 1
					if Input.is_action_just_pressed("ui_down") :
						pos_edited_with_keyboard = true
						grid_pos.y += 1
					if Input.is_action_just_pressed("ui_right") :
						pos_edited_with_keyboard = true
						grid_pos.x += 1
					if Input.is_action_just_pressed("ui_left") :
						pos_edited_with_keyboard = true
						grid_pos.x -= 1
				else : 
					if Input.is_action_just_pressed("ui_up") : grid_length += 1
					if Input.is_action_just_pressed("ui_down") : 
						grid_length -= 1
						if grid_length < 1 : grid_length = 1
					if Input.is_action_just_pressed("ui_right") : width += 1.
					if Input.is_action_just_pressed("ui_left") : width -= 1.
				#respond to mouse editing (where it is minus the difference between where the grid says it should be and where it actually should be with offsets, divided by the grid_size gives the grid_pos)
				if !pos_edited_with_keyboard :
					if horizontal :
						grid_pos.x = round((position.x + grid_offset.x - grid_size/2) / grid_size)
						grid_pos.y = round((position.y + grid_offset.y) / grid_size)
					else : 
						grid_pos.x = round((position.x + grid_offset.x) / grid_size)
						grid_pos.y = round((position.y + grid_offset.y - grid_size/2) / grid_size)

		#makes sure other nodes grid size and offset export are up to date
		grid_size = grid_size_
		grid_offset = grid_offset_
		set_display()
	
		if snap :
			position = Vector2(grid_pos) * grid_size_ - grid_offset_
			if horizontal : position.x += grid_size_/2
			else : position.y += grid_size_/2
			length = grid_length * grid_size_ + width

func set_display() :
	if horizontal :
		col.shape.size = Vector2(length, width)
		sprite.scale = Vector2(length, width)
	else :
		col.shape.size = Vector2(width, length)
		sprite.scale = Vector2(width, length)
	sprite.position = Vector2.ZERO
	sprite.modulate = color
