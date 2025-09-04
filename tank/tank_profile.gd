extends Resource
class_name TankProfile

## All tanks must have a tank profile at all times
## Note player tanks will have a PlayerProfile (extends from TankProfile)
## Since tank may be used for several different things TankProfile has several use cases / extensions
##  - Player tanks - tank controlled by a player
##        Each player tank should have its own profile, bc scoring and so different players can have different colors
##        Set is_player=true, shows_in_scoring=true, make sure the keybinds are set to input actions
##  - Laika tanks - computer controlled tank that is like a player, has a score etc
##        Use different profiles, bc scoring
##        Set is_player=false, shows_in_scoring=true, keybinds don't need to be set (bots are controlled directly through method calls)
##  - Temporary enemy tanks - they all look the same, they don't exist outside of a single level
##        If ur ok with colors being the same, can use the same profile for all of them
##        Set is_player=false, shows_in_scoring=false, keybinds don't need to be set

#tank association
var has_associated_tank : bool = false
var associated_tank_id : int

# tank settings #TODO
#var tank_color
#var tank_secondary_color

func is_player() :
	return typeof(PlayerProfile)

func associate(tank_id : int) :
	has_associated_tank = true
	associated_tank_id = tank_id

func dissociate() :
	has_associated_tank = false
	
