extends Node

func _process(_delta):
	#quit if Q pressed - DEBUG
	if Input.is_action_pressed("DEBUG_QUIT") : get_tree().quit()
