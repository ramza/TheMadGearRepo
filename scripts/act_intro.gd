extends Node2D

onready var timer = get_node("Timer")
var counter = 0
export var map_index = 0

func _on_timer_timeout():
	game.goto_scene(game.maps[map_index])

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
