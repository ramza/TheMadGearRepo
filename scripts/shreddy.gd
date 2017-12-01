extends "player.gd"

func special_attack(motion):
	mp -= special_cost
	if(game.is_2_player and !player_1):
		game.HUD.update_player2_special_bar(float(mp)/max_mp)
	else:
		game.HUD.update_special_bar(float(mp)/max_mp)
	motion = Vector2(0,0)
	state = STATES.SPECIAL
	can_attack = false
	attack_timer.set_wait_time(0.6)
	attack_timer.start()
	var axe = shreddy_axe.instance()
	axe.set_pos(punch_position.get_global_pos())
	axe.set_scale(scale)
	if(!player_1):
		axe.set_player_one(false)
	game.current_scene.add_child(axe)
	camera.shake(2,15,2)
	return motion
