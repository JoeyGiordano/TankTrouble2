extends AnimatedSprite2D
class_name LoadoutSprite

@onready var tank_loadout : TankLoadout = self.get_parent().get_parent()

# notes for setup
# each LoadoutSprite Node (animated sprite 2d) will need a master sprite sheet
# which holds animations corresponding for each independent character sprite
# onready, the LoadoutSprite will look at ths sprite ID and select the correct animation accordingly

# on startup, the loadout sprite will select the correct animation based on the chosen sprite ID
# selects stationary sprite to begin
func _ready() :
	pass
	# TODO: Poblem here, returning 0s <<<<
	#var loadout_sprite_id : int = tank_loadout.get_sprite_id()
	#print("LOADOUT SPRITE SEES: ",loadout_sprite_id)
	#match loadout_sprite_id:
		#0:	# tank sprite 1
			#self.play("grey_rat_idle")
		#1:	# tank sprite 2
			#self.play("white_rat_idle")
		#2:	# tank sprite 3
			#self.play("tan_rat_idle")
		#_:	# rat sprite 1
			#self.play("tank_1_idle")
		
#make it so when tank/rat is moving, it selects the animation to move
func _process(_delta) :
	pass
