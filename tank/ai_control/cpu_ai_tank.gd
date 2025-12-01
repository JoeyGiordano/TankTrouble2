extends AIController2D
# Stores the action sampled for the agent's policy, running in python
var move_action : Vector2 = Vector2.ZERO
var shoot_action : bool = 0

const MAP_SIZE_X = 1024
const MAP_SIZE_Y = 1024
const MAX_BULLET_SPEED = 10
const MAX_WALLS = 10
const MAX_BULLETS = 5
const MAX_ENEMIES = 4

#OBSERVATIONS
var wall_group : Node2D
var bullet_group : Node2D
var enemy_group : Node2D
var walls : Array[Node2D]
var bullets : Array[RigidBody2D]
var enemies : Array[Node2D]

#REWARDS
var survival: float = 1
var is_dead: float = -10

var survival_acc: float = 0

var is_dead_flag: bool = false
var killed_self_flag: bool = false #unused


func _ready():
	wall_group = Global.LevelHolder.get_child(0).get_node("Walls")
	#WARNING WARNING ENEMY TANK MAY BE IN PLAYERTANKS CHILD
	enemy_group = Global.NpcTanks
	enemy_group.remove_child(self)
	bullet_group = Global.Bullets
func _get_sorted_children(base: Node2D, max_count: int) -> Array:
	var children = base.get_children()
	children.sort_custom(_calc_distance)
	if children.size() > max_count:
		children = children.slice(0, max_count)
	while children.size() < max_count:
		children.append(null)
	return children
func _calc_distance(obj : Node2D) -> float:
	return (self.position-obj.position).length_squared()
func get_obs() -> Dictionary:
	walls = _get_sorted_children(wall_group,MAX_WALLS)
	bullets = _get_sorted_children(bullet_group,MAX_BULLETS)
	enemies = _get_sorted_children(enemy_group,MAX_ENEMIES)
	var obs_bullets : Array[float] = []
	var obs_walls : Array[float] = []
	var obs_tanks : Array[float] = []
	for n in walls:
		if n == null:
			obs_walls.append_array([0,0,0,0,0])
		else:
			obs_walls.append_array([n.position.x / MAP_SIZE_X, n.position.y  / MAP_SIZE_X, n.scale.x, n.scale.y,1])
	for b in bullets:
		if b == null:
			obs_bullets.append_array([0,0,0,0,0])
		else:
			obs_bullets.append_array([b.position.x, b.position.y, b.linear_velocity.x / MAX_BULLET_SPEED, b.linear_velocity.y / MAX_BULLET_SPEED,1])
	for e in enemies:
		if e == null:
			obs_tanks.append_array([0,0,0,0])
		else:
			obs_tanks.append_array([e.position.x, e.position.y, e.rotation,1])
	return {"walls":obs_walls, "bullets":obs_bullets, "tanks":obs_tanks}

func _process(delta: float) -> void:
	survival_acc += delta * survival
func get_reward() -> float:
	var reward: float = 0
	reward += survival_acc
	reward += is_dead
	return reward

func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		},
		"shoot_action" : {
			"size" : 1,
			"action_type": "discrete"
		}
		}

func set_action(action) -> void:
	move_action = Vector2(clamp(action["move_action"][0], -1.0, 1.0), clamp(action["move_action"][1],-1.0,1.0))
	shoot_action = action["shoot_action"][0]
