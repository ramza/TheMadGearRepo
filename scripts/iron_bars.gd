extends KinematicBody2D

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var area = get_node("Area2D")

var explosion = preload("res://scenes/big_explosion.tscn")
const STATES = {
	"IDLE": 0,
	"DAMAGE_1":1,
	"DAMAGE_2":2,
	"DAMAGE_3":3
}

var state
var hp = 4
var active_portal = false

func take_damage(damage, type):
	if(!active_portal):
		hp -= damage
		sample_player.play("hurt")
		if(hp == 3):
			state = STATES.DAMAGE_1
		elif(hp == 2):
			state = STATES.DAMAGE_2
		elif(hp == 3):
			state = STATES.DAMAGE_3
		elif( hp<=0):
			death()

func _on_timer_timeout():
	game.goto_scene(game.maps[2])
func death():
	var e = explosion.instance()
	e.set_global_pos(get_global_pos())
	game.current_scene.add_child(e)
	active_portal = true
	set_process(false)
	anim.play("open")

func _on_body_enter(body):
	if(active_portal and body.is_in_group("heroes")):
		game.HUD.play_fade("fade_out")
		
		game.player.disable()
		if(game.is_2_player):
			game.player2.disable()
		timer.start()

	
func _process(delta):
	var anim_name = "idle"
	if(state == STATES.IDLE):
		anim_name = "idle"
	elif(state == STATES.DAMAGE_1):
		anim_name = "damage_1"
	elif(state == STATES.DAMAGE_2):
		anim_name = "damage_2"
	elif(state == STATES.DAMAGE_3):
		anim_name = "damage_3"
	
	anim.play(anim_name)

func _ready():
	state = STATES.IDLE
	area.connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	set_process(true)
