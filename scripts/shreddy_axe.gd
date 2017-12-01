extends "hero_punch.gd"

func extended_behavior():
	damage = 5
	set_type("special")
	sample_player = get_node("SamplePlayer2D")
	sample_player.play("axe")
