extends Resource
class_name LevelRegion

### Sort of like a binary tree, but without any sorting just direction and orientation and lots of overlap[br]
## credits to this link: https://jonoshields.com/post/bsp-dungeon/ for getting the ball rolling here [br][br]
##
## pos is the top_left corner of every tile, therefore
## the actual tile area of a region is: pos.x/y + scale.x/y - 1

var dl_region : LevelRegion ##down or left subregion
var ur_region : LevelRegion ##up or right subregion
var pos : Vector2i ##top-left corner of region
var area : Vector2i
var generator : Node ##the level generator of the region

func _init(pos_ : Vector2i, area_ : Vector2i):
	self.pos = pos_
	self.area = area_

#returns leaves from this region
func get_undivided_subregions() -> Array[LevelRegion]:
	if dl_region == null and ur_region == null:
		return [self]
	else:
		return dl_region.get_undivided_subregions() + ur_region.get_undivided_subregions()
