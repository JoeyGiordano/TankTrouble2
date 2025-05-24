@tool
extends Node2D
class_name Wall

@export var update : bool = false

@export var horizontal : bool = false
@export var length : float = 100.0
@export var width : float = 8.0
@export var color : Color = Color.WHITE

@onready var col : CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	update = true

func _process(_delta):
	if update :
		update = false
		if horizontal :
			col.shape.size = Vector2(length, width)
			sprite.scale = Vector2(length, width)
		else  :
			col.shape.size = Vector2(width, length)
			sprite.scale = Vector2(width, length)
		sprite.position = Vector2.ZERO
		sprite.modulate = color
