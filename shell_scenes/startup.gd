extends Node

var x = false

func _ready() -> void:
	await get_tree().create_timer(2.2).timeout
	if x : return
	ShellSceneManager.switch_active_scene(Ref.icon)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		x =true
		ShellSceneManager.switch_active_scene(Ref.icon)
