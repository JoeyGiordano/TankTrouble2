extends CollisionPolygon2D
class_name TankCollisionPolygon

func set_polygon_by_gun_name(gun_name : String) :
	match gun_name :
		"do_nothing" : set_polygon_("rect")
		"default" : set_polygon_("default")
		_ :
			print("unrecognized gun name")
			set_polygon_("rect")
		
func set_polygon_(polygon_name : String) :
	var p : Polygon2D
	for i in get_child_count():
		if get_child(i).name == polygon_name :
			polygon = get_child(i).polygon
			return
	print("unrecognized polygon name")
