class_name Stats

var forward_speed : float
var backward_speed : float
var rotation_speed : float

func add_stats(s : Stats) :
	forward_speed += s.forward_speed
	backward_speed += s.backward_speed
	rotation_speed += s.rotation_speed

func subtract_stats(s : Stats) :
	forward_speed -= s.forward_speed
	backward_speed -= s.backward_speed
	rotation_speed -= s.rotation_speed

func copy() -> Stats :
	var s = Stats.new()
	s.forward_speed = forward_speed
	s.backward_speed = backward_speed
	s.rotation_speed = rotation_speed
	return s

func as_string() -> String :
	var s = ""
	s = s+"Forward Speed: " + str(forward_speed) + "\n"
	s = s+"Backward Speed: " + str(backward_speed) + "\n"
	s = s+"Rotation Speed: " + str(rotation_speed) + "\n"
	return s

static func get_tank_base_stats_copy() -> Stats :
	var s = Stats.new()
	s.forward_speed = 150.0
	s.backward_speed = 100.0
	s.rotation_speed = 4.0
	return s
