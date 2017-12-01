extends Node2D

onready var timer = get_node("Timer")
onready var anim = get_node("AnimationPlayer")

var flag = true

func _on_desk_girl_timer_timeout():
	if(flag):
		anim.play("idle")
	else:
		anim.play("wave")
	flag = !flag

func _ready():
	timer.connect("timeout", self, "_on_desk_girl_timer_timeout")
	timer.start()