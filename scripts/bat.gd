extends Area2D

onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var sprite = get_node("Sprite")

var active = true

func _on_bat_body_enter(body):
	if(body.is_in_group("heroes") and active):
		sample_player.play("powerup")
		sprite.hide()
		active = false
		body.has_bat = true
		timer.start()
		
func _on_bat_timer_timeout():
	queue_free()

func _ready():
	connect("body_enter", self, "_on_bat_body_enter")
	timer.connect("timeout", self, "_on_bat_timer_timeout")
