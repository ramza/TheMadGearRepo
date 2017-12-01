#projectile script
extends KinematicBody2D

export var velocity = Vector2(-1,0)
export var speed = 100
export var damage = 1
export var explosion = false

var small_explosion = preload("res://scenes/small_explosion.tscn")

onready var area = get_node("Area2D")
onready var timer = get_node("Timer")

func _on_area_body_enter(body):
	if(body.is_in_group("heroes") and
	abs(body.get_pos().y - self.get_pos().y) < 15 ):
		body.take_damage("knife", damage)
		if(explosion):
			var e = small_explosion.instance()
			e.set_global_pos(get_global_pos())
			game.current_scene.add_child(e)
		queue_free()

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
