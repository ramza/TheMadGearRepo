extends Node2D

onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")

func _on_timer_timeout():
	game.goto_scene(game.maps[0])

func _ready():
	sample_player.play("electricity")
	timer.connect("timeout", self, "_on_timer_timeout")
	
