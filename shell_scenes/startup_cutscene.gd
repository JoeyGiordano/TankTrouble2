extends Sprite2D

func _ready() -> void:
	get_parent().get_child(0).play("startup_anim")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		next_scene()

func next_scene() :
	ShellSceneManager.switch_active_scene(Ref.main_menu)
