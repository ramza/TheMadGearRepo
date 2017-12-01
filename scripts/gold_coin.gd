extends "food.gd"

func do_effect():
	if(target != null and !triggered and !immune and active and abs(target.get_global_pos().y +10 -get_global_pos().y) < 5):
			triggered = true
			active = false
			target.update_score(200)
			sample_player.play("powerup")
			sprite.set_hidden(true)
			timer.start()
