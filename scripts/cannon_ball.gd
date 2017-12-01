extends KinematicBody2D

onready var area = get_node("Area2D")
var speed = 200

func _process(delta):
	var velocity = Vector2(1, 0)
	var motion = velocity*speed*delta
	motion = move(motion)

func _on_body_enter(body):
	if body.is_in_group("enemies"):
		body.take_damage(3, "special")

func _ready():
	area.connect("body_enter", self, "_on_body_enter")
	set_process(true)
	
