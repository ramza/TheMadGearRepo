extends Area2D

onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var audio = get_node("SamplePlayer2D")

var attack = preload("res://scenes/enemy_punch.tscn")

func _on_body_enter(body):
	if body.is_in_group("heroes"):
		sprite.show()
		timer.start()
		audio.play("spooky")
		audio.play("lightning")
		var punch = attack.instance()
		punch.set_global_pos(get_global_pos())
		game.current_scene.add_child(punch)

func _on_timer_timeout():
	queue_free()

func _ready():
	sprite.hide()
	connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout",self,"_on_timer_timeout")