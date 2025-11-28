extends Node2D
class_name RegionManager

### Data tree of level_regions[br]
## This script manages the regions and the generation of each region's bones[br]
## credits to this link: https://jonoshields.com/post/bsp-dungeon/ for getting the ball rolling here

##used in pit placement, when one region finds itself unable to place the pits it was expected to,[br]
##it sends the pits required for the limit to the next generator to take care of, and so on and so forth.
signal overloaded_pits(overload : int)

var overhead : LevelGenerator
var domain : LevelRegion #root region

##storage for the above signal
var overload_pits : int = 0

var region_total : int = 0

#root is the whole level area
#root's position is on origin_marker, area is dictated by gen_bounds
func _init(domain_ : LevelRegion, overhead_ : LevelGenerator):
	self.domain = domain_
	self.overhead = overhead_
	overloaded_pits.connect(_overload_pit_queue)

func _overload_pit_queue(overload : int):
	overload_pits += overload

#region utility
#borrowed and tweaked from Joey :3
#do be aware that the first parameter of func_name MUST be able to take a region or else this will not work :)
func call_func_with_regions_of(root_region : LevelRegion, func_source : Object, func_name : String, args : Array = []) :
	if not func_source.has_method(func_name):
		return #requiring an apt function
	var focus_regions : Array[LevelRegion] = [root_region]
	while not focus_regions.is_empty():
		var new_regions : Array[LevelRegion] = []
		for i in focus_regions:
			if i.dl_region != null:
				new_regions.append(i.dl_region)
			if i.ur_region != null:
				new_regions.append(i.ur_region)
			func_source.callv(func_name,[i] + args)
		focus_regions = new_regions

## getting touching regions of a provided region; does not allow corner cases (only corners touching)
func get_touching_regions_of(region : LevelRegion) -> Array[LevelRegion]:
	var results : Array[LevelRegion] = []
	var region_rect : Rect2 = Rect2(region.pos,region.area)
	for t in domain.get_undivided_subregions():
		#don't check itself
		if not t == region:
			#running checks for corner cases that would pass through the intersection test (but are useless for our needs)
			if not (t.pos.x == region.pos.x + region.area.x and t.pos.y + t.area.y == region.pos.y): #top right of focus
				if not (t.pos.x == region.pos.x + region.area.x and t.pos.y == region.pos.y + region.area.y): #bottom right of focus
					if not (t.pos.x + t.area.x == region.pos.x and t.pos.y == region.pos.y + region.area.y): # bottom left of focus
						if not (t.pos.x + t.area.x == region.pos.x and t.pos.y + t.area.y == region.pos.y): #top left of focus
							var test_rect : Rect2 = Rect2(t.pos,t.area)
							if test_rect.intersects(region_rect,true):
								results.append(t)
	return results

## returns the rect of the shape of focus_region that lie on the border touching border_region[br]
## grow_dir is required to tell focus_region where to expand into so you recieve the right (or any) border rect
func get_border_rect_with(focus_region : LevelRegion, border_region : LevelRegion, grow_dir : int) -> Rect2:
	#we expand the focus_rect so tiles between borders are actually intersections!
	return Rect2(focus_region.pos,focus_region.area).intersection(Rect2(border_region.pos,border_region.area).grow_side((grow_dir+2)%4,1))

## returns the direction of the border of focus_region that shares a border with border_region from the center of focus_region[br]
## sides numbers are from enum Side (used for Rect2)
func get_shared_border_direction_with(focus_region : LevelRegion, border_region : LevelRegion) -> int:
	if border_region.pos.x == focus_region.pos.x + focus_region.area.x: #right
		return 2
	elif border_region.pos.y == focus_region.pos.y + focus_region.area.y: #bottom
		return 3
	elif border_region.pos.x < focus_region.pos.x and border_region.pos.y + border_region.area.y > focus_region.pos.y: #left
		return 0
	else: #top
		return 1

## relying on the 4 cardinal directions here; converting to hexagons directions + offsets (if needed)
func direction_to_offset_region(direction : int) -> Vector2i:
	match direction:
		0: return Vector2i.UP
		1: return Vector2i.RIGHT
		2: return Vector2i.DOWN
		3: return Vector2i.LEFT
	return Vector2i.ZERO

## same as sides_on_level_border_of() but instead focusing on region borders
func sides_on_region_border_of(region : LevelRegion, coords : Vector2i) -> Array[int]:
	var results : Array[int] = []
	if coords.y <= region.pos.y:
		results.append(0)
	if coords.x >= region.pos.x+region.area.x-1:
		results.append(1)
	if coords.y >= region.pos.y+region.area.y-1:
		results.append(2)
	if coords.x <= region.pos.x:
		results.append(3)
	return results

#endregion

#region generation
func generate_regions():
	#every region created is split into 2 for every region_division
	for i in overhead.region_divisions:
		split_regions(domain.get_undivided_subregions());
	region_total = domain.get_undivided_subregions().size()
	queue_redraw()
	generate_regions_bones()

func split_regions(regions : Array[LevelRegion]):
	for i in regions:
		var horizontal_split : bool = i.area.x <= i.area.y #splitting horizontal when there's more y, vertically with more x
		var split_percent : float = 0.1
		if horizontal_split:
			split_percent = randf_range(float(overhead.region_min_size)/float(i.area.y),float(i.area.y-overhead.region_min_size)/float(i.area.y))
		else:
			split_percent = randf_range(float(overhead.region_min_size)/float(i.area.x),float(i.area.x-overhead.region_min_size)/float(i.area.x))
		#no regions smaller than region_min_size
		if horizontal_split:
			if floori(float(i.area.y)/2.0) < overhead.region_min_size:
				continue
		elif floori(float(i.area.x)/2.0) < overhead.region_min_size: 
			continue
		if horizontal_split:
			var border_height = max(overhead.region_min_size,roundi(split_percent*i.area.y))
			i.dl_region = LevelRegion.new(Vector2i(i.pos.x,i.pos.y+border_height),Vector2i(i.area.x,i.area.y-border_height))
			i.ur_region = LevelRegion.new(i.pos,Vector2i(i.area.x,border_height))
		else:
			var border_breadth = max(overhead.region_min_size,roundi(split_percent*i.area.x))
			i.dl_region = LevelRegion.new(i.pos,Vector2i(border_breadth,i.area.y))
			i.ur_region = LevelRegion.new(Vector2i(i.pos.x+border_breadth,i.pos.y),Vector2i(i.area.x-border_breadth,i.area.y))

#determines what kind of generator to run and then runs it for regions
func generate_regions_bones():
	connect_all_regions()
	var regions : Array[LevelRegion] = domain.get_undivided_subregions()
	for i in range(len(regions)):
		#applying pits
		var region_pits : int = 0
		if overhead.pits_left > 0:
			match overhead.region_pit_rules:
				0:
					if not i == regions.size()-1:
						region_pits = ceili(float(overhead.level_pits)/float(region_total))
					else:
						region_pits = overhead.pits_left
					overhead.pits_left = max(0,overhead.pits_left-region_pits)
				1:
					if i == regions.size()-1:
						region_pits = overhead.pits_left
					else:
						region_pits = randi_range(0,overhead.pits_left)
					overhead.pits_left -= region_pits
		#generator and overloading management
		var gta_generator = GTARegionGenerator.new(regions[i],overhead,region_pits+overload_pits)
		overload_pits = 0
		add_child(gta_generator)
		regions[i].generator = gta_generator
		gta_generator.skeleton_builder()
#endregion

#region connecting regions
## makes everything connect to everything else based on region_connections
func connect_all_regions():
	match overhead.region_connections:
		0: #every region to every direction (except borders)
			#WARNING: this setting will not guarantee a connection to all regions if an entire region that is void is generated
			for i in domain.get_undivided_subregions():
				if not i.pos.y <= 0: #north
					var coords : Vector2i = Vector2i(randi_range(roundi(i.pos.x),roundi(i.pos.x+i.area.x-1)),i.pos.y)
					overhead.get_map_bone(coords).sides[0] = 2
					overhead.get_map_bone(coords+direction_to_offset_region(0)).sides[2] = 2
				if not i.pos.x+i.area.x >= overhead.gen_bounds.x: #right
					var coords : Vector2i= Vector2i(i.pos.x+i.area.x-1,randi_range(roundi(i.pos.y),roundi(i.pos.y+i.area.y-1)))
					overhead.get_map_bone(coords).sides[1] = 2
					overhead.get_map_bone(coords+direction_to_offset_region(1)).sides[3] = 2
				if not i.pos.y+i.area.y >= overhead.gen_bounds.y: #bottom
					var coords : Vector2i= Vector2i(randi_range(roundi(i.pos.x),roundi(i.pos.x+i.area.x-1)),i.pos.y+i.area.y-1)
					overhead.get_map_bone(coords).sides[2] = 2
					overhead.get_map_bone(coords+direction_to_offset_region(2)).sides[0] = 2
				if not i.pos.x <= 0: #left
					var coords : Vector2i= Vector2i(i.pos.x,randi_range(roundi(i.pos.y),roundi(i.pos.y+i.area.y-1)))
					overhead.get_map_bone(coords).sides[2] = 3
					overhead.get_map_bone(coords+direction_to_offset_region(3)).sides[1] = 2
		1: #every region to every touching region
			for i in domain.get_undivided_subregions():
				for j in get_touching_regions_of(i):
					_connect_bordering_regions(i,j)
		_: #base connections (minimum neccessary, probably)
			call_func_with_regions_of(domain,self,"_connect_subregions",[])

func _connect_subregions(region : LevelRegion):
	#no more to connect
	if region.dl_region == null and region.ur_region == null:
		return
	#buddyless regions connections (obnoxious edge cases)
	#I give it a buddy by looking for touching regions...
	elif region.dl_region == null or region.ur_region == null:
		var solo_region : LevelRegion
		if region.dl_region == null:
			solo_region = region.dl_region
		else:
			solo_region = region.ur_region
		var touching_regions : Array[LevelRegion] = get_touching_regions_of(solo_region)
		var touch_region : LevelRegion
		while true: #NOTE: will be more useful for restricting touching regions later!
			touch_region = touching_regions.pop_at(randi_range(0,touching_regions.size()))
			break
		_connect_bordering_regions(solo_region,touch_region)
	else:
		#connecting big region's subregions
		_connect_bordering_regions(region.dl_region,region.ur_region)

## we're assuming the regions passed are bordering
## should really only be running through connect_region()
func _connect_bordering_regions(focus_region : LevelRegion,border_region : LevelRegion):
	var border_dir = get_shared_border_direction_with(focus_region,border_region)
	var intersection = get_border_rect_with(focus_region,border_region,border_dir)
	#getting a random tile from intersection
	var coords = Vector2i(randi_range(roundi(intersection.position.x),roundi(intersection.end.x-1)),randi_range(roundi(intersection.position.y),roundi(intersection.end.y-1)))
	#putting a opening on these bones to connect regions in bone generation
	border_dir = (border_dir+3)%4 #switching from Side side to LevelGenBone side
	overhead.get_map_bone(coords).sides[border_dir] = 2
	#getting the other side of the connection a 2
	match border_dir:
		0: coords += Vector2i.UP
		1: coords += Vector2i.RIGHT
		2: coords += Vector2i.DOWN
		3: coords += Vector2i.LEFT
	overhead.get_map_bone(coords).sides[(border_dir+2)%4] = 2
#endregion

#TEST: debug drawing
func _draw():
	for r in domain.get_undivided_subregions():
		var real_pos : Vector2i = overhead.pos_to_position(r.pos)
		draw_rect(Rect2(real_pos.x,real_pos.y,r.area.x * overhead.scale_.x,r.area.y * overhead.scale_.y), Color.BLACK,false,1)
