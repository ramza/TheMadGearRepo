extends KinematicBody2D

const STATES = {
	"RISE": 1,
	"HOVER": 2,
	"DROP": 3
}

var state = STATES.HOVER

var speed = 40

var counter = 0;
var sound_delay = 3

onready var timer = get_node("Timer")
onready var area = get_node("Area2D")
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var drop_point = get_node("drop_point")

var ninja_drop = preload("res://scenes/ninja_drop.tscn")

var drop_complete = false
var active = false
var rise_count = 0
export var ninjas_to_spawn = 2
var ninja_count = 0

func _on_timer_timeout():
	timer.stop()
	if(get_global_pos().y < -100):
		set_process(false)
		queue_free()
	elif(state == STATES.RISE):
		if(!drop_complete):
			state = STATES.HOVER
			set_process(false)
		timer.set_wait_time(1)
		timer.start()
			
	elif(state == STATES.HOVER):
		if(ninja_count < ninjas_to_spawn):
			ninja_count+=1
			var ninja = ninja_drop.instance()
			ninja.set_global_pos(drop_point.get_global_pos())
			game.current_scene.add_child(ninja)
		else:
			drop_complete = true
			state = STATES.RISE
			set_process(true)
		timer.set_wait_time(3)
		timer.start()

func _process(delta):
	counter += 0.1
	if(counter >= sound_delay):
		counter = 0
		sample_player.play("chopper")
		
	var motion = Vector2(0,0)
	
	if(state == STATES.RISE):
		motion = Vector2(0, -1)
		
	motion = motion*speed*delta
	motion = move(motion)

func _on_body_enter(body):
	if( !active and body.is_in_group("heroes")):
		active = true
		area.disconnect("body_enter", self, "_on_body_enter")
		state = STATES.RISE
		set_process(true)
		timer.set_wait_time(3)
		timer.start()

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	area.connect("body_enter", self, "_on_body_enter")