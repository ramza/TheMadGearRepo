extends "guard.gd"

var knife = preload("res://scenes/knife.tscn")

func time_to_punch():
	if(abs(target.get_pos().x - self.get_pos().x) < max_distance *4 and 
	   abs(target.get_pos().y - self.get_pos().y) < min_y/2):
		return true
	else:
		return false

func punch():
	state = STATES.PUNCH
	var k = knife.instance()
	k.set_pos(punch_position.get_global_pos())
	k.set_scale(scale)
	if(scale.x == -1):
		k.set_velocity(Vector2(1, 0))
	game.current_scene.add_child(k)
	can_punch = false
	punch_timer.start()