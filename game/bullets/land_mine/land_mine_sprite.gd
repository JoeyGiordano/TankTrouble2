extends Sprite2D

var i : int = 0

func _process(_delta: float) -> void:
	i+=1
	if i == 24 :
		frame = !frame
		i=0
	
