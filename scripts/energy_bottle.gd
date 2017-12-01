extends "food.gd"

func do_effect():
	if(target != null and abs(target.get_global_pos().y +10 -get_global_pos().y) < 5):
			active = false
			target.drink_bottle(100)
			sample_player.play("drink")
			sprite.set_hidden(true)
			timer.start()