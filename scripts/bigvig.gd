extends "player.gd"

var whip_scene = preload("res://scenes/whip.tscn")

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
	var whip = whip_scene.instance()
	whip.set_pos(punch_position.get_global_pos())
	whip.set_scale(scale)
	if(!player_1):
		whip.set_player_one(false)
	game.current_scene.add_child(whip)
	camera.shake(2,15,2)
	return motion
