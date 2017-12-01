extends "guard.gd"

var bullet = preload("res://scenes/bullet.tscn")

func time_to_punch():
	if(abs(target.get_pos().x - self.get_pos().x) < max_distance *5 and 
	   abs(target.standing_pos - self.standing_pos) < min_y/2):
		return true
	else:
		return false

func punch():
	state = STATES.PUNCH
	var b = bullet.instance()
	b.set_pos(punch_position.get_global_pos())
	b.set_scale(scale)
	if(scale.x == -1):
		b.set_velocity(Vector2(1, 0))
	game.current_scene.add_child(b)
	can_punch = false
	punch_timer.start()
