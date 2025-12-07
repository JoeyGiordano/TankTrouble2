extends Button

var players_ready_already_called : bool = false

func _ready() -> void:
	pressed.connect(press)
	
func press() :
	if players_ready_already_called : return #ensures GameManager.game_loop() is only called once
	players_ready_already_called = true
	GameManager.players_ready.emit()
