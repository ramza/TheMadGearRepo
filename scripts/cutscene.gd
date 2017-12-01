extends Node2D

onready var anim = get_node("AnimationPlayer")
export var play_sound = false
onready var sample_player = get_node("SamplePlayer")
export var audio_name = "sample"
export var wait_time = 1
export var play_sound_2 = false

export var audio_name_2 = "sample2"
export var wait_time_2 = 1

export var cutscene = 0
var intro_delay = 100
var intro_counter = 0 
var counter = 0

func _ready():
	anim.connect("finished", self, "_on_anim_finished")
	set_process(true)

func _process(delta):
	intro_counter += 1
	if(intro_counter > intro_delay and Input.is_action_pressed("start")):
		game.goto_scene(game.cutscenes[cutscene])
		
	counter += 0.1

	if(counter > wait_time and play_sound):
		play_sound = false
		_on_timer_timeout()
	if(play_sound_2 and counter > wait_time_2):
		play_sound_2 = false
		_on_timer2_timeout()

func _on_timer2_timeout():
	sample_player.play(audio_name_2)

func _on_timer_timeout():
	sample_player.play(audio_name)
	
func _on_anim_finished():
	game.goto_scene(game.cutscenes[cutscene])
