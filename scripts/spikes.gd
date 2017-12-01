extends Area2D

const STATES = {
	"IDLE":1,
	"ATTACK":2,
	"WITHDRAW":3
}
export var hits_enemy = false
var state
var prevState
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var hit_position = get_node("hit_position")

var active = false
var target
var enemy_punch = preload("res://scenes/enemy_punch.tscn")
var hero_punch = preload("res://scenes/hero_punch.tscn")

func _on_timer_timeout():
	pass

func _on_anim_finished():
	if(state == STATES.ATTACK and prevState != STATES.IDLE):
	
		state = STATES.WITHDRAW
	elif(state == STATES.WITHDRAW):
		state = STATES.IDLE
		active = false

func _on_body_exit(body):
	target = null
	active = false

func _on_body_enter(body):
	if(body.is_in_group("heroes") or body.is_in_group("enemies")):
		target = body
		active = true
			
func _process(delta):
	if(active and target.is_in_group("heroes") and target.state != target.STATES.JUMP and abs(target.get_global_pos().y +10 -get_global_pos().y) < 10):
			active = false
			timer.start()
			state = STATES.ATTACK
			var punch = enemy_punch.instance()
			punch.set_global_pos(get_global_pos())
			game.current_scene.add_child(punch)
			target = null
		
	elif(active and target.is_in_group("enemies")):
			active = false
			timer.start()
			state = STATES.ATTACK
			var punch = hero_punch.instance()
			punch.is_spikes = true
			punch.set_global_pos(get_global_pos())
			game.current_scene.add_child(punch)
			target = null
	
	var anim_name = "idle"
	if(state == STATES.IDLE):
		anim_name = "idle"
	elif(state == STATES.ATTACK):
		anim_name = "attack"
	elif(state == STATES.WITHDRAW):
		anim_name = "withdraw"
	
	if(!anim.is_playing() or state == STATES.IDLE):
		anim.play(anim_name)
	
	prevState = state

func _ready():
	state = STATES.IDLE
	prevState = state
	connect("body_exit", self, "_on_body_exit")
	connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	anim.connect("finished", self, "_on_anim_finished")
	set_process(true)