extends KinematicBody2D

onready var anim = get_node("AnimationPlayer")
onready var muzzle = get_node("muzzle")
onready var timer = get_node("Timer")
onready var audio = get_node("SamplePlayer2D")
onready var area = get_node("Area2D")

var STATES = {
	"IDLE": 0,
	"FIRE": 1,
	"FUSE": 2
}

var state
var standing_pos
var cannon_ball = preload("res://scenes/cannon_ball.tscn")
var active = false

func take_damage():
	if(!active):
		active = true
		audio.play("his")
		anim.play("fuse")
		state = STATES.FUSE

func _on_cannon_anim_finished():
	if(state == STATES.FIRE):
		print(state)
		state = STATES.IDLE
		anim.play("idle")
	elif(state == STATES.FUSE):
		state = STATES.FIRE
		anim.play("fire")
		var shot = cannon_ball.instance()
		shot.set_global_pos(muzzle.get_global_pos())
		game.current_scene.add_child(shot)
		audio.play("cannon")
		timer.start()

func _on_cannon_timer_timeout():
	timer.stop()
	active = false
	
func _on_body_enter(body):
	if(body.is_in_group("heroes")):
		game.remove_from_character_list(self)
		self.queue_free()

func _ready():
	standing_pos = get_global_pos().y + 10
	state = STATES.IDLE
	anim.play("idle")
	anim.connect("finished", self, "_on_cannon_anim_finished")
	timer.connect("timeout", self, "_on_cannon_timer_timeout")
	area.connect("body_enter", self, "_on_body_enter")
	game.add_to_character_list(self)
	pass
