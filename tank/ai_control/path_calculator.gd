extends Node2D
class_name path_calculator
@export var distance_limit: float
@export var bounce_limit : int

var MAX_DIST = 10000
var debug_lines : Array[Vector2]
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	debug_lines.clear()
	calc_path(Vector2(Vector2.RIGHT.rotated(global_rotation)))
	#print(str(global_rotation) + " " + str(Vector2(Vector2.RIGHT.rotated(global_rotation))))
func calc_path(dir : Vector2):
	#print("ray dir " + str(dir))
	calc_path_limit(global_position,dir,distance_limit,bounce_limit,[get_parent()])
	pass
func calc_path_limit(pos: Vector2, dir : Vector2, limit_dist : float, _bounce_limit: int, exclude : Array[RID]):
	if limit_dist < 0 || _bounce_limit < 0: 
		#print("hit limit: " + str(limit_dist) + " " + str(_bounce_limit))
		return
	var space = PhysicsServer2D.space_get_direct_state(get_world_2d().space)
	var query = PhysicsRayQueryParameters2D.create(pos, dir * MAX_DIST, 1 | 2, exclude)
	var result = space.intersect_ray(query)
	#print("ray results: " + str(result))
	if result.get("rid") == null:
		#debug_lines.clear()
		print("hit nothing")
		return
	var collider: CollisionObject2D = result.get("collider")
	if collider.collision_layer & 2:
		print("hit tank " + str(bounce_limit - _bounce_limit))
		var script = collider.get_script()
		if script is Tank:
			var tank_script : Tank = script
			if tank_script.profile.is_player():
				#SHOOT
				pass
		return
	var new_pos = result.get("position")
	var distance = (new_pos - pos).length()
	var normal = result.get("normal")
	var new_dir = -dir.rotated(2 * ((-dir).angle_to(normal)))
	#print("next dir: " + str(new_dir))
	debug_lines.append(pos - global_position)
	debug_lines.append(new_pos - global_position)
	queue_redraw()
	calc_path_limit(new_pos, new_dir, limit_dist - distance, _bounce_limit - 1,[result.get("rid")])
func _draw():
	for i in debug_lines.size() - 1:	
		draw_line(debug_lines[i].rotated(-global_rotation), debug_lines[i+1].rotated(-global_rotation), Color.RED,1)
		i+=1
