#laser script
extends KinematicBody2D

var velocity = Vector2(0,1)
var speed = 100
var damage = 1

onready var area = get_node("Area2D")
onready var timer = get_node("Timer")

func _on_area_body_enter(body):
	if(body.is_in_group("heroes")):
		body.take_damage("laser", damage)
		
func _on_timer_timeout():
	queue_free()

func _ready():
	area.connect("body_enter", self, "_on_area_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	set_process(true)
	
func _process(delta):
	var motion = velocity * speed * delta
	move(motion)