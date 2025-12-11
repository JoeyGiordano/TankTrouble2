extends Node

@onready var add_player_button : Button = $AddPlayerButton
@onready var remove_player_button : Button = $RemovePlayerButton
@onready var message_label : Label = $MessageLabel
@onready var play_button : Button = $PlayButton
@onready var players_container : HBoxContainer = $CenterContainer/PlayersContainer

# scene that handles changing player sprites
@export var player_selector_scene : PackedScene
@export var available_sprites : Array[Texture2D] = []

var player_count : int = 0
const MIN_PLAYERS = 2
const MAX_PLAYERS = 3

var player_selectors : Array[Control] = []

# TODO: Connect the correct corresponding players up 
# and down inputs to signals to inc/dec through sprites
# so mouse does not need to be shared by all players for sprite selection
func _ready() : 
	add_player_button.pressed.connect(on_add_player_pressed)
	remove_player_button.pressed.connect(on_remove_player_pressed)
	play_button.pressed.connect(on_play_pressed)
	_set_player_count(2) #intialize selection
	

func _process(_delta) :
	if Input.is_action_just_pressed("DEBUG_SKIP") :
		_set_player_count(2)
		play_button.pressed.emit()

func on_add_player_pressed() :
	AudioManager.play(Ref.item_spawn_sfx)
	if player_count < MAX_PLAYERS :
		_set_player_count(player_count + 1)
	else :
		message_label.text = ""#"Player max reached"
		await get_tree().create_timer(1.7).timeout
		message_label.text = ""

func on_remove_player_pressed() :
	AudioManager.play(Ref.tank_death_sfx)
	if player_count > MIN_PLAYERS :
		_set_player_count(player_count - 1)

# TODO: create_players needs to changed to take in player_count as well as selected_sprites
func on_play_pressed() :
	# TODO: following lines can be uncommented once PlayerManager.create_players is modified
	var player_sprite_ids: Array[int] = []
	if player_count == 2 :
		player_sprite_ids.append(player_selectors[0].get_selected_sprite_id())
		player_sprite_ids.append(player_selectors[1].get_selected_sprite_id())
	if player_count == 3 :
		player_sprite_ids.append(player_selectors[0].get_selected_sprite_id())
		player_sprite_ids.append(player_selectors[2].get_selected_sprite_id())
		player_sprite_ids.append(player_selectors[1].get_selected_sprite_id())
		
	#for p in player_selectors:
	#	player_sprite_ids.append(p.get_selected_sprite_id())
	PlayerManager.create_players(player_count, player_sprite_ids)
	Global.MainAudio().stop()
	Global.MainAudio2().play()
	GameManager.players_ready.emit()
	# PlayerManager.create_players(player_count)

#func add_update_graphic() :
	#match player_count :
		#2 : 
			#$PlayerGraphic1.hide()
			#$PlayerGraphic2.show()
		#3 :
			#$PlayerGraphic2.hide()
			#$PlayerGraphic3.show()
#
#func remove_update_graphic() :
	#match player_count :
		#1 : 
			#$PlayerGraphic2.hide()
			#$PlayerGraphic1.show()
		#2 :
			#$PlayerGraphic3.hide()
			#$PlayerGraphic2.show()

func _set_player_count(new_count : int) -> void:
	new_count = clamp(new_count, MIN_PLAYERS, MAX_PLAYERS)
	if new_count == player_count:
		return
	
	# add selectors if needed
	while player_selectors.size() < new_count:
		var selector := player_selector_scene.instantiate()
		selector.player_index = player_selectors.size() + 1
		# selector.sprites = available_sprites
		
		selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		selector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		players_container.add_child(selector)
		player_selectors.append(selector)
	
	# remove selectors if needed
	while player_selectors.size() > new_count:
		var last_selector = player_selectors.pop_back()
		last_selector.queue_free()
	
	player_count = new_count
