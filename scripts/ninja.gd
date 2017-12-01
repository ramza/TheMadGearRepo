extends "guard.gd"

func punch():
	state = STATES.PUNCH
	var punch = enemy_punch.instance()
	punch.set_pos(punch_position.get_global_pos())
	punch.set_scale(scale)
	game.current_scene.add_child(punch)
	can_punch = false
	punch_timer.start()