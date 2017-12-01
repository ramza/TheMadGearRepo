extends KinematicBody2D

const STATES = {
	"IDLE": 0,
	"BREAK": 1
}

var state
var prev_state
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var spawn = get_node("cyborg_spawn")
var cyborg = preload("res://scenes/unfinished_cyborg.tscn")

var hp = 1

func take_damage(damage, type):
	hp -= damage
	if(hp <= 0):
		sample_player.play("glass_break")
		game.camera.shake(1,7,1)
		state = STATES.BREAK

func _process(delta):
	
	var name
	if(state == STATES.IDLE):
		name = "idle"
	elif(state == STATES.BREAK):
		name = "break"
	if(!anim.is_playing() or 
	state == STATES.BREAK and prev_state != STATES.BREAK):
		anim.play(name)
	prev_state = state

func _on_cyborg_tank_anim_finished():
	if(state == STATES.BREAK):
		var c = cyborg.instance()
		c.set_global_pos(spawn.get_global_pos())
		game.current_scene.add_child(c)
		queue_free()

func _ready():
	state = STATES.IDLE
	prev_state = state
	anim.connect("finished", self, "_on_cyborg_tank_anim_finished")
	set_process(true)
