extends Node2D
class_name LevelGenWall

#NOTE: most certaintly needs to be reworked, this is for testing purposes for now

@onready var sprite : Sprite2D = $Sprite2D
@onready var collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D
@export var scale_ : Vector2 = Vector2(1,1)
#borrows physics material from wall.tscn

func _ready():
	collision_shape.shape.size = scale_
	sprite.scale = Vector2(scale_.x,scale_.y/2)
