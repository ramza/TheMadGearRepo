extends KinematicBody2D

const STATES = {
   "IDLE": 0,
   "DAMAGE1": 1,
   "DAMAGE2": 2,
	"DAMAGE3": 3,
	"FALL": 4,
	"DEATH": 5
}
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var sparks = get_node("Particles2D")
onready var text_1 = get_node("text_1")
onready var text_2 = get_node("text_2")
onready var text_timer = get_node("text_timer")

var text_flag = false

var active = true
var explosion = preload("res://scenes/big_explosion.tscn")
var state
var prev_state
var hp = 18
var max_hp = 20

func take_damage(damage, type):
	if(active):
		hp -= damage
		sparks.set_emitting(true)
		timer.start()
		game.camera.shake(1,7,1)
		sample_player.play("hurt")
		if(hp <= 0):
			timer.start()
			var e = explosion.instance()
			sample_player.play("explode")
			e.set_global_pos(get_global_pos())
			game.current_scene.add_child(e)
			get_node("Sprite").set_hidden(true)
			active = false
		elif(hp <= max_hp/4 ):
			state = STATES.DAMAGE3
		elif(hp <= max_hp/3):
			state = STATES.DAMAGE2
		elif(hp <= max_hp-(max_hp*0.25)):
			state = STATES.DAMAGE1

func _process(delta):
	var animationName
	if(state == STATES.IDLE):
		animationName = "idle"
	elif(state == STATES.DAMAGE1):
		animationName = "damage1"
	elif(state == STATES.DAMAGE2):
		animationName = "damage2"
	elif(state == STATES.DAMAGE3):
		animationName = "damage3"
	
	if(!anim.is_playing() or
	(state == STATES.DAMAGE1 and prev_state != STATES.DAMAGE1)):
		anim.play(animationName)
		
	prev_state = state

func _on_text_timer_timeout():
	text_1.hide()
	text_2.hide()
	if(text_flag):
		text_flag = false
		if(rand_range(0,10) < 5):
			text_1.show()
		else:
			text_2.show()
	else:
		text_flag = true
			
	
	
	
func _on_timer_timeout():
	timer.stop()
	if(hp <= 0):
		queue_free()
	else:
		sparks.set_emitting(false)
	
func _ready():
	state = STATES.IDLE
	prev_state = state
	set_process(true)
	timer.connect("timeout", self, "_on_timer_timeout")
	text_timer.connect("timeout", self, "_on_text_timer_timeout")
	sparks.set_emitting(false)
	text_timer.start()
