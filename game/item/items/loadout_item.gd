extends Node2D

@export var loadout : String

func _ready() -> void:
	if loadout != "" :
		var r : ItemResource = $Item.item_res.duplicate()
		r.loadout_name = loadout
		$Item.item_res = r
			

func _process(_delta: float) -> void:
	if get_child_count() != 4 :
		queue_free()
