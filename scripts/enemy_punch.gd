extends Area2D

onready var timer = get_node("Timer")
var type = "punch"
var damage = 1
var active = true

func _on_timer_timeout():
	queue_free()
	
func set_damage(d):
	damage = d
# when a body enters the punch area we check to see if its a hero
# if so, we make sure we're active so that we don't hit more than once
func _on_body_enter(body):
	if(body.is_in_group("heroes") and active and abs(body.get_pos().x - get_pos().x) < 20):
		#turn off the punch so that we don't strick twice before the punch is cleaned up
		active = false
		if(body.state != body.STATES.FALL):
			get_node("Sprite").set_rot(rand_range(0, 360))
			get_node("Sprite").set_hidden(false)
		body.take_damage(type, damage)
	
func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	connect("body_enter", self, "_on_body_enter")
	timer.start()
	