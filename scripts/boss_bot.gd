extends "guard.gd"

var missle = preload("res://scenes/missle.tscn")

func time_to_punch():
	if(abs(target.get_pos().x - self.get_pos().x) < max_distance *6 and 
	   abs(target.get_pos().y - self.get_pos().y) < min_y*3):
		return true
	else:
		return false

func punch():
	state = STATES.PUNCH
	var weapon = missle.instance()
	weapon.set_pos(punch_position.get_global_pos())
	weapon.set_scale(scale)
	if(scale.x == -1):
		weapon.set_velocity(Vector2(1, 0))
	game.current_scene.add_child(weapon)
	can_punch = false
	punch_timer.set_wait_time(rand_range(0,2))
	punch_timer.start()
