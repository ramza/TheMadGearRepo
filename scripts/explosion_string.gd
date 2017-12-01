extends Node2D

var big_explosion = preload("res://scenes/big_explosion.tscn")
onready var timer = get_node("Timer")

var xoffset = 50
var yoffset = 100
var total_explosion = 10
var counter = 0

func _on_timer_timeout():
	timer.stop()
	counter += 1
	if(counter > total_explosion):
		queue_free()
	var e = big_explosion.instance()
	var x = rand_range(-xoffset, xoffset)
	var y = rand_range(-yoffset, yoffset)
	var new_pos = Vector2(get_global_pos().x+x, get_global_pos().y+y)
	e.set_global_pos(new_pos)
	game.current_scene.add_child(e)
	timer.set_wait_time(rand_range(0,1))
	timer.start()

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	pass
