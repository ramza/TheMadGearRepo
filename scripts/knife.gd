#knife script
extends KinematicBody2D

var velocity = Vector2(-1,0)
var speed = 200
var damage = 2

onready var area = get_node("Area2D")
onready var timer = get_node("Timer")

func _on_area_body_enter(body):
	if(body.is_in_group("heroes") and
	abs(body.get_pos().y - self.get_pos().y) < 20 ):
		body.take_damage("knife", damage)
		queue_free()
	var dis_y = body.get_pos().y - self.get_pos().y
	if(dis_y > 0):
		set_z(body.get_z()-1)
		if(get_z() == 0):
			body.set_z(0)
	else:
		set_z(body.get_z()+1)
func _ready():
	area.connect("body_enter", self, "_on_area_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	set_process(true)
	
func _on_timer_timeout():
	queue_free()
	
func set_velocity(new_velocity):
	velocity = new_velocity
	
func _process(delta):
	var motion = velocity * speed * delta
	move(motion)