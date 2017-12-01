extends Area2D

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")

var active = true

var vampire = preload("res://scenes/vampire.tscn")

func _on_body_enter(body):
	if(active and body.is_in_group("heroes")):
		active = false
		anim.play("open")
		sample_player.play("vampire_laugh")
		timer.start()
		
func _on_timer_timeout():
	var vamp = vampire.instance()
	vamp.set_global_pos(get_global_pos())
	game.current_scene.add_child(vamp)
	queue_free()

func _ready():
	anim.play("idle")
	connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	pass
