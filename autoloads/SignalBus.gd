extends Node
class_name _SignalBus

### AUTOLOAD

### SignalBus ###
## Holds all the signals for easy access

# Game Loop Events
signal begin_round
signal end_round


func test_all_signals() :
	# Godot gives a warning if you don't use a signal in the script in which it is created
	# This function is here to prevent that warning
	# I see no reason why you would ever want to call this
	# Maybe Signal bus is a bad idea and everything should be returned to its place of use, who knows
	begin_round.emit()
	end_round.emit()
