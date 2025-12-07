extends Sprite2D

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	frame = 1
	await get_tree().create_timer(0.07).timeout
	frame = 2
	await get_tree().create_timer(0.1).timeout
	frame = 3
	await get_tree().create_timer(0.15).timeout
	frame = 4
	AudioManager.play(Ref.pipe_fall)
	await get_tree().create_timer(0.2).timeout
	frame = 5
	await get_tree().create_timer(3).timeout
	frame = 6
	await get_tree().create_timer(2).timeout
	frame = 7
	await get_tree().create_timer(1.3).timeout
	frame = 8
	await get_tree().create_timer(1.7).timeout
	next_scene()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		next_scene()

func next_scene() :
	ShellSceneManager.switch_active_scene(Ref.main_menu)
