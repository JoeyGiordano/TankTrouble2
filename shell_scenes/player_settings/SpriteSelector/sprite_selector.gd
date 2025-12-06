extends Control
class_name SpriteSelector

@onready var sprite_display : Sprite2D = $sprite_display
@onready var sprite_selection : AnimatedSprite2D = $sprite_selection
@onready var prev_button : Button = $PrevButton
@onready var next_button : Button = $NextButton
@onready var label : Label = $PlayerLabel

# Sprites to be displayed and iterated through
# @export var sprites : Array[Texture2D] = []
const MAX_SPRITES = 6
@export var player_index : int = 0

# current sprite being displayed
var current_index : int = 0

func _ready() -> void:
	label.text = "Player %d" % player_index
	# connect the buttons
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	_update_sprite()

func _on_prev_pressed() -> void:
	current_index -= 1
	_update_sprite()
	
func _on_next_pressed() -> void:
	current_index += 1
	_update_sprite()
	
func _update_sprite() -> void:
	if (MAX_SPRITES == 0):
		return
	# keep in range of sprite array
	current_index = wrapi(current_index, 0, MAX_SPRITES)
	#sprite_display.texture = sprites[current_index]
	match(current_index):
		0:
			sprite_selection.play("grey_rat_idle")
		1:
			sprite_selection.play("white_rat_idle")
		2:
			sprite_selection.play("tan_rat_idle")
		3:
			sprite_selection.play("tank_white_idle")
		4:
			sprite_selection.play("tank_green_idle")
		_:
			sprite_selection.play("tank_red_idle")
		

#func get_selected_sprite() -> Texture2D:
	#if (sprites.is_empty()):
		#return null
	#return sprites[current_index]
	
func get_selected_sprite_id() -> int:
	return current_index
