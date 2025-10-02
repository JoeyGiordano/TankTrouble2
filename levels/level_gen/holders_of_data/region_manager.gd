extends Node2D
class_name RegionManager

### Data tree of level_regions[br]
## This script manages the regions and the generation of each region's bones[br]
## credits to this link: https://jonoshields.com/post/bsp-dungeon/ for getting the ball rolling here

var overhead : LevelGenerator
var domain : LevelRegion #root region

#root is the whole level area
#root's position is on origin_marker, area is dictated by gen_bounds
func _init(root : LevelRegion, overhead_ : LevelGenerator):
	self.domain = root
	self.overhead = overhead_

func generate_regions():
	#every region created is split into 2 for every region_division
	for i in overhead.region_divisions:
		split_regions(domain.get_undivided_subregions());
	queue_redraw()
	generate_regions_bones(domain)

func split_regions(regions : Array[LevelRegion]):
	for i in regions:
		var split_percent : float = randf_range(0.1,0.9) #NOTE: should be made into export variable...
		var horizontal_split : bool = i.area.x <= i.area.y #splitting horizontal when there's more y, vertically with more x
		#no regions smaller than 1x1
		if horizontal_split and i.area.x <= 1:
			continue
		if not horizontal_split and i.area.y <= 1: 
			continue
		if horizontal_split:
			var border_height = max(1,int(split_percent*i.area.y))
			i.dl_region = LevelRegion.new(Vector2i(i.pos.x,i.pos.y+border_height),Vector2i(i.area.x,i.area.y-border_height))
			i.ur_region = LevelRegion.new(i.pos,Vector2i(i.area.x,border_height))
		else:
			var border_breadth = max(1,int(split_percent*i.area.x))
			i.dl_region = LevelRegion.new(i.pos,Vector2i(border_breadth,i.area.y))
			i.ur_region = LevelRegion.new(Vector2i(i.pos.x+border_breadth,i.pos.y),Vector2i(i.area.x-border_breadth,i.area.y))

#determines what kind of generator to run and then runs it for regions
func generate_regions_bones(root_region):
	var regions : Array[LevelRegion] = root_region.get_undivided_subregions()
	for i in regions:
		var gta_generator = GTARegionGenerator.new(i,overhead,0)
		add_child(gta_generator)
		i.generator = gta_generator
		gta_generator.skeleton_builder()
	connect_regions(domain)

#makes everything connect to everything else based on region_connections
func connect_regions(root_region : LevelRegion):
	var regions : Array[LevelRegion] = root_region.get_undivided_subregions()
	for i in regions:
		var region_bones : Array[Array] = overhead.region_to_bones(i)
		if region_bones.all(func(b): return b == null): #don't run on void regions
			continue
		match overhead.region_connections:
			0: #all directions
				match overhead.tile_type: #NOTE: this is going to be just to work enough for no tile_limit, I'll make it more advanced later
					overhead.TILE_TYPE.SQUARE: #NOTE: plans to make this handle connecting regions with placing bones if the region can't connect to anything
						var possible_connections : Array[LevelGenBone]
						#right
						if not i.pos.x + i.area.x-1 >= overhead.map_bones.size()-1: #don't bridge on border
							possible_connections = []
							for j : LevelGenBone in region_bones[region_bones.size()-1]:
								if j != null:
									if j.sides[1] == 1:
										possible_connections.append(j)
							var connector : LevelGenBone = possible_connections.pick_random()
							connector.sides[1] = 2
							overhead.get_map_bone(connector.coords + overhead.direction_to_offset(1)).sides[overhead.inverse_direction(1)] = 2
						#down
						if not i.pos.y + i.area.y-1 >= overhead.map_bones[0].size()-1: #don't bridge on border
							possible_connections = []
							for j : Array[LevelGenBone] in region_bones:
								if j[region_bones[0].size()-1] != null:
									if j[region_bones[0].size()-1].sides[2] == 1:
										possible_connections.append(j[region_bones[0].size()-1])
							var connector : LevelGenBone = possible_connections.pick_random()
							connector.sides[2] = 2
							overhead.get_map_bone(connector.coords + overhead.direction_to_offset(2)).sides[overhead.inverse_direction(2)] = 2
					overhead.TILE_TYPE.HEXAGON:
						pass #TODO: make this work after BSP regions with hexagons are made to work correctly!

#TEST: debug drawing
func _draw():
	for r in domain.get_undivided_subregions():
		var real_pos : Vector2i = overhead.pos_to_position(r.pos)
		draw_rect(Rect2(real_pos.x,real_pos.y,r.area.x * overhead.scale_.x,r.area.y * overhead.scale_.y), Color.BLACK,false,1)
