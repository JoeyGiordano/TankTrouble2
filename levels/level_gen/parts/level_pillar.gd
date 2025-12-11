extends Node2D
class_name LevelGenPillar

@onready var sprite : Sprite2D = $Sprite2D
@onready var collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var area : Area2D = $Area2D

var to_destroy : bool = true

func _ready():
	sprite.frame = randi_range(0,sprite.hframes-1)
	collision_shape.shape.size = Vector2(6,6)
	area.body_entered.connect(on_body_entered)
	await get_tree().create_timer(0.1).timeout
	if to_destroy : queue_free()

func on_body_entered(b : Node2D) :
	if b.get_parent().is_in_group("level_gen_wall") :
		to_destroy = false
	
