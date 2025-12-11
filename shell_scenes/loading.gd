extends Control

@onready var score0 = $Score0
@onready var score1 = $Score1
@onready var score2 = $Score2

var r : bool = false
var p : bool = false

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	r = true

func _process(_delta: float) -> void:
	if r && Input.is_anything_pressed() :
		p = true
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		p = true

func display_score() :
	
	if GameInfo.num_players == 2 :
		score0.text = score_to_string(GameInfo.score0)
		score1.visible = false
		score2.text = score_to_string(GameInfo.score1)
	if GameInfo.num_players == 3 :
		score0.text = score_to_string(GameInfo.score0)
		score1.text = score_to_string(GameInfo.score2)
		score2.text = score_to_string(GameInfo.score1)
	
	while true :
		await get_tree().create_timer(0.02).timeout
		if p :
			return

func score_to_string(score : int) :
	if score < 10 :
		return "0" + str(score)
	else :
		return str(score)
