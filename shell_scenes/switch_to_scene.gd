extends Button

@export var switch_to : String #name of the scene that this button will switch to
@export var 	quick_key : bool #debug, allows faster skipping around, simulate pressing the button by pressing a "1", should only be on for one button per scene

func _ready() :
	#connect the button's pressed signal to on_pressed()
	connect("pressed", on_pressed)

func _process(_delta):
	if quick_key && Input.is_action_just_pressed("DEBUG_SKIP"):
		on_pressed()

func on_pressed() :
	#tell the GameContainer to switch the scene to the scene with the name switch_to
	GameContainer.GC.switch_to_scene(switch_to)
