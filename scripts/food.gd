#food script
extends Area2D

export var health_bonus = 3
export var type = "burger"
var active = false
var immune = true
var triggered = false
export var score_value = 3

onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var sprite = get_node("Sprite")
var target 

func _on_body_enter(body):
	if(body.is_in_group("heroes")):
		target = body
		active = true
		
func _on_body_exit(body):
	if(target != null and body == target):
		active = false
	
func do_effect():
	if(target != null and !triggered and !immune and active and abs(target.get_global_pos().y +10 - get_global_pos().y) < 10):
		triggered = true
		active = false
		target.eat_food(type, health_bonus)
		target.new_text_popup("+"+str(score_value))
		target.update_score(score_value)
		sample_player.play("powerup")
		sprite.set_hidden(true)
		timer.start()

func _process(delta):
	if(target != null and active and overlaps_body(target)):
		do_effect()

func _on_timer_timeout():
	if(!immune):
		queue_free()
	else:
		immune = false
	timer.stop()

func _ready():
	timer.start()
	connect("body_enter", self, "_on_body_enter")
	connect("body_exit", self, "_on_body_exit")
	timer.connect("timeout", self, "_on_timer_timeout")
	set_process(true)