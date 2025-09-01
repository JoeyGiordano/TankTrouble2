extends Node
class_name _Utility

### AUTOLOAD

### Utility ###
## This autoload stores commonly used or bulky methods for use in other scripts.

func replace_scene_in_holder(holder_node : Node, new_scene : PackedScene) :
	#replace the scene in the holder_node (ShellSceneHolder, LevelHolder, etc) with a newly instantiated scene from PackedScene new_scene
	#holder_node should only hold one node at a time
	#use Reference to get scenes (and sometimes holders) instead of loading them yourself!
	remove_scene_in_holder(holder_node)
	var s = new_scene.instantiate()
	holder_node.add_child(s)
	#purposely don't return s. The user of this function should instead access it from the holder_node, for clarity and consistency

func remove_scene_in_holder(holder_node : Node) :
	match holder_node.get_child_count() :
		0 : pass
		1 : 
			holder_node.get_child(0).queue_free()
			holder_node.remove_child(holder_node.get_child(0))
		_ : print("Utility.replace_scene_in_holder() used on holder node " + holder_node.name + " with more than one child. " + holder_node.name + " had " + str(holder_node.get_child_count) + " children." )

### Debug Helpers ###

func print_node_signal_connections(node : Node, do_print : bool = true) -> String :
	# Iterate over all signals defined in this node and print their connections
	var output : String = "" # prep to store the printed strings
	for _signal in node.get_signal_list(): # cycle through every signal in the node
		if do_print : print("Signal: " + _signal.name + "\n" + "---") # print header
		output += "Signal: " + _signal.name + "\n" + "---" + "\n" # store header
		var connections = node.get_signal_connection_list(_signal.name) # get the signal's connections
		for c in connections : # cycle through every connection (array of dicts)
			var method_name = str(c.get("callable", "_")) # the connected method
			var flags = str(c.get("flags", "_")) # the flags associated with the connected method
			if do_print : print(method_name + "\t\t\t" + flags) # print the connection info
			output += method_name + "\t\t\t" + flags + "\n" # store the connection info
		if do_print : print("-------------") # print footer
		output += "-------------" + "\n" # store footer
	return output

func print_signal_connections(s : Signal, do_print : bool = true) -> String :
	#print all connections to the signal s, return the printout string, optionally don't print
	var output : String = "" # prep to store the printed strings
	if do_print : print("Signal: " + s.get_name() + "\n" + "---") # print header
	output += "Signal: " + s.get_name() + "\n" + "---" + "\n" # store header
	var connections = s.get_connections() # get the signal's connections
	for c in connections :  # cycle through every connection (array of dicts)
		var method_name = str(c.get("callable", "_")) # the connected method
		var flags = str(c.get("flags", "_")) # the flags associated with the connected method
		if do_print : print(method_name + "\t\t\t" + flags) # print the connection info
		output += method_name + "\t\t\t" + flags + "\n" # store the connection info
	if do_print : print("-------------") # print footer
	output += "-------------" + "\n" # store footer
	return output
	
## Duplicates

func _print_node_signal_connections(node : Node, do_print : bool = true) :
	# Iterate over all signals defined in this node and print their connections
	for _signal in node.get_signal_list(): # cycle through every signal in the node
		print("Signal: " + _signal.name + "\n" + "---") # print header
		var connections = node.get_signal_connection_list(_signal.name) # get the signal's connections
		for c in connections : # cycle through every connection (array of dicts)
			var method_name = str(c.get("callable", "_")) # the connected method
			var flags = str(c.get("flags", "_")) # the flags associated with the connected method
			print(method_name + "\t\t\t" + flags) # print the connection info
		print("-------------") # print footer

func _print_signal_connections(s : Signal) :
	#print all connections to the signal s, return the printout string, optionally don't print
	print("Signal: " + s.get_name() + "\n" + "---") # print header
	var connections = s.get_connections() # get the signal's connections
	for c in connections :  # cycle through every connection (array of dicts)
		var method_name = str(c.get("callable", "_")) # the connected method
		var flags = str(c.get("flags", "_")) # the flags associated with the connected method
		print(method_name + "\t\t\t" + flags) # print the connection info
	print("-------------") # print footer
