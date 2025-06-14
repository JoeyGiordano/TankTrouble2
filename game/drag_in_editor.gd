@tool
extends Node2D

var grid_pos : Vector2

func _process(delta) :
	if Engine.is_editor_hint() :
		grid_pos = Grid.nearest_vertical_edge_center(position, Grid.COORD_TYPE.REAL, Grid.COORD_TYPE.GRID)
	
	position = Grid.grid_to_real(grid_pos)
		
