extends TankControlScheme
class_name PlayerControl

func calculate_inputs() :
	move.x = Input.get_axis("player" + str(tank.player_id) + "_left", "player" + str(tank.player_id) + "_right")
	move.y = Input.get_axis("player" + str(tank.player_id) + "_down", "player" + str(tank.player_id) + "_up")
	shoot = Input.is_action_just_pressed("player" + str(tank.player_id) + "_shoot")
