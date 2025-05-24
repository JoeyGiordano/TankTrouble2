extends Node2D
class_name Gun


func shoot() :
	#should be overridden by child class
	#print("shot fired")
	pass

func forward() -> Vector2 :
	return transform.x

func backward() -> Vector2 :
	return -transform.x

func left() -> Vector2 :
	return -transform.y

func right() -> Vector2 :
	return transform.y
	
