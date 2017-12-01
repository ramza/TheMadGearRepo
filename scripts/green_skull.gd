extends Area2D

onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var audio = get_node("SamplePlayer2D")
onready var anim = get_node("AnimationPlayer")

var attack = preload("res://scenes/enemy_punch.tscn")

var target = null
var active

func _on_body_exit(body):
	if body == target:
		target = null
		active = false
		set_process(false)

func skull_attack():
	sprite.show()
	timer.start()
	audio.play("spooky")
	anim.play("spin")
	audio.play("lightning")
	var punch = attack.instance()
	punch.set_global_pos(get_global_pos())
	game.current_scene.add_child(punch)

func _on_body_enter(body):
	if body.is_in_group("heroes"):
		target = body
		active = true
	
	set_process(true)

func _process(delta):
	if active and abs(target.standing_pos - get_global_pos().y) < 5:
		skull_attack()
		active = false

func _on_timer_timeout():
	queue_free()

func _ready():
	sprite.hide()
	connect("body_enter", self, "_on_body_enter")
	connect("body_exit",self,"_on_body_exit")
	timer.connect("timeout",self,"_on_timer_timeout")