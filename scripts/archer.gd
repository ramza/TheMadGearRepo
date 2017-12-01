extends "guard.gd"

var arrow = preload("res://scenes/arrow.tscn")

func time_to_punch():
	if(abs(target.get_pos().x - self.get_pos().x) < max_distance *3 and 
	   abs(target.get_pos().y - self.get_pos().y) < min_y):
		return true
	else:
		return false

func punch():
	state = STATES.PUNCH
	var a = arrow.instance()
	a.set_pos(punch_position.get_global_pos())
	a.set_scale(scale)
	if(scale.x == -1):
		a.set_velocity(Vector2(1, 0))
	game.current_scene.add_child(a)
	can_punch = false
	punch_timer.start()
