extends "player.gd"

var flaming_skull = preload("res://scenes/flaming_skull.tscn")
var skull_amount = 7

func special_attack(motion):
	if(!sample_player.is_voice_active(0)):
		sample_player.play("special")
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
	for i in range(skull_amount):
		var skull = flaming_skull.instance()
		var pos = Vector2()
		pos.y = punch_position.get_global_pos().y - rand_range(100, 200)
		if(scale.x == 1):
			pos.x = punch_position.get_global_pos().x - rand_range(50, 300)
		else:
			pos.x = punch_position.get_global_pos().x + rand_range(100, 300)
		skull.set_pos(pos)
		skull.set_scale(scale)
		if(!player_1):
			skull.set_player_one(false)
		skull.motion_start = Vector2(scale.x, 1)
		game.current_scene.add_child(skull)
	camera.shake(2,15,2)
	return motion
