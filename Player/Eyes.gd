extends Node2D



func get_location():
	for eye in get_children():
		if(eye.is_colliding()):
			return eye.get_collision_point()
			pass
		pass
	return Vector2.ZERO
	pass

func get_object():
	for eye in get_children():
		if(eye.is_colliding()):
			return eye.get_collider()
			pass
		pass
	return null
	pass
