extends Node2D
class_name LevelGenWall

@onready var sprite : Sprite2D = $Sprite2D
@onready var collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D
#borrows physics material from wall.tscn

func _ready():
	sprite.frame = randi_range(0,sprite.hframes-1)
	collision_shape.shape.size = Vector2(6,78)
