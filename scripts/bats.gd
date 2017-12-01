extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var particles = get_node("Particles2D")
onready var area = get_node("Area2D")
onready var timer = get_node("Timer")
onready var audio = get_node("SamplePlayer2D")

var flag = false
var active = false

func _on_bats_body_enter(body):
	if(body.is_in_group("heroes")):
		active = true
		particles.set_emitting(true)
		timer.start()

func _on_bats_timer_timeout():
	if(flag):
		queue_free()
	else:
		particles.set_emitting(false)
		timer.set_wait_time(3)
		flag = true

func _process(delta):
	if(active):
		if(!audio.is_voice_active(0)):
			audio.play("bats")

func _ready():
	area.connect("body_enter", self, "_on_bats_body_enter")
	timer.connect("timeout", self, "_on_bats_timer_timeout")
	set_process(true)
