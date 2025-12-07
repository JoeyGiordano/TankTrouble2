extends Control

func _ready() -> void:
	if !Global.MainAudio().playing :
		Global.MainAudio().play()
	if Global.MainAudio2().playing :
		Global.MainAudio2().stop()
