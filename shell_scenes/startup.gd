extends Node

func _ready() -> void:
	await get_tree().create_timer(1.2).timeout
	ShellSceneManager.switch_active_scene(Ref.icon)
