extends "player.gd"

var piano_scene = preload("res://scenes/piano.tscn")
var piano_amount = 5

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
	for i in range(piano_amount):
		var piano = piano_scene.instance()
		var pos = Vector2()
		
		pos.x = punch_position.get_global_pos().x - rand_range(-50, 50)
		pos.y = punch_position.get_global_pos().y - rand_range(150, 300)
		piano.set_pos(pos)
		piano.set_scale(scale)
		if(!player_1):
			piano.set_player_one(false)
		game.current_scene.add_child(piano)
	camera.shake(2,15,2)
	return motion
