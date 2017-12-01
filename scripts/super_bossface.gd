extends KinematicBody2D

const STATES = {
   "IDLE": 0,
   "DAMAGE1": 1,
   "FACE": 2,
	"DAMAGE3": 3,
	"FALL": 4,
	"DEATH": 5
}

var active = true
var state
var prev_state
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var cannon_timer = get_node("cannon_timer")
onready var cannon_1 = get_node("cannon_1")
onready var cannon_2 = get_node("cannon_2")

var missle = preload("res://scenes/missle.tscn")
var explosion_string = preload("res://scenes/explosion_string.tscn")

var missle_switch = false
var timer_range = 4
var hp = 50

func Death():
	cannon_timer.stop()
	active = false
	state = STATES.DEATH
	sample_player.play("long_explosion")
	var e = explosion_string.instance()
	e.set_global_pos(get_global_pos())
	game.current_scene.add_child(e)
	state = STATES.DEATH
	timer.set_wait_time(7)
	timer.start()

func take_damage(damage, type):
	if(active):
		sample_player.play("boss_hurt")
		hp -= damage
		game.HUD.update_boss_health_icons(hp)
		state = STATES.DAMAGE1
		if(hp <= 0):
			Death()
			game.player.disable()
			if(game.is_2_player):
				game.player2.disable()
		else:
			timer.set_wait_time(1)
			timer.start()
		
func _on_cannon_timer_timeout():
	game.HUD.initialize_boss(hp)
	cannon_timer.stop()
	var m = missle.instance()
	if(missle_switch):
		m.set_global_pos(cannon_1.get_global_pos())
	else:
		m.set_global_pos(cannon_2.get_global_pos())
	if(rand_range(0,10) < 5):
		missle_switch = !missle_switch
	game.current_scene.add_child(m)
	cannon_timer.set_wait_time(rand_range(1,timer_range))
	cannon_timer.start()
	
func _on_timer_timeout():
	if(state == STATES.DEATH ):
		state = STATES.IDLE
		game.player1_score = game.player.score
		if game.is_2_player:
			game.player2_score = game.player2.score
		game.goto_scene("res://scenes/ending.tscn")
	if(state == STATES.DAMAGE1):
		state = STATES.FACE

func _process(delta):
	var anim_name = "face"
	if(state == STATES.IDLE):
		anim_name = "idle"
	elif(state == STATES.FACE):
		anim_name = "face"
	elif(state == STATES.DAMAGE1):
		anim_name = "hurt"
	elif(state == STATES.DEATH):
		anim_name = "death"
	if(!anim.is_playing() or
	state == STATES.DAMAGE1 and prev_state != state or
	state == STATES.DEATH and prev_state != state):
		anim.play(anim_name)
		
	prev_state = state

	if(!sample_player.is_voice_active(0)):
		var r = int(rand_range(0,3))
		if r == 0:
			sample_player.play("talk_1")
		elif r==1:
			sample_player.play("talk_2")
		else:
			sample_player.play("talk_3")
func _ready():
	state = STATES.FACE
	prev_state = state
	cannon_timer.connect("timeout", self, "_on_cannon_timer_timeout")
	timer.connect("timeout", self, "_on_timer_timeout")
	cannon_timer.start()
	set_process(true)
	pass
