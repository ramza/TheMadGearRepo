extends Node2D

onready var timer = get_node("Timer")
onready var timer2 = get_node("Timer2")
onready var sample_player = get_node("SamplePlayer2D")
onready var anim = get_node("AnimationPlayer")
onready var start_label = get_node("start_label")
onready var player1_label = get_node("player1_label")
onready var player2_label = get_node("player2_label")
onready var quit_button = get_node("quit_button")

var animation 
var player_choice = false

func _on_timer_timeout():
	timer.stop()
	anim.stop()
	if(player_choice):
		game.goto_scene(game.maps[1])
	player_choice = true
	start_label.set_hidden(true)
	player1_label.set_hidden(false)
	player2_label.set_hidden(false)
	animation = "player1_flash" 
	set_process(true)

func _on_timer2_timeout():
	game.goto_scene("res://scenes/leaderboard.tscn")

func _on_button_down():
	get_tree().quit()

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	timer2.connect("timeout", self, "_on_timer2_timeout")
	quit_button.connect("button_down", self, "_on_button_down")
	game.player1_score = 0
	game.player2_score = 0
	game.game_over = false
	set_process(true)
	
func _process(delta):
	var start = Input.is_action_pressed("start")
	var up = Input.is_action_pressed("move_up")
	var down = Input.is_action_pressed("move_down")
	var y  = Input.is_action_pressed("jump")

#	if Input.is_key_pressed(KEY_1):
#		game.goto_scene(game.maps[2])
#	elif Input.is_key_pressed(KEY_2):
#		game.goto_scene(game.maps[5])
#	elif Input.is_key_pressed(KEY_3):
#		game.goto_scene(game.maps[8])
#	elif Input.is_key_pressed(KEY_4):
#		game.goto_scene(game.maps[12])
#	elif Input.is_key_pressed(KEY_5):
#		game.goto_scene(game.maps[15])


	if(y):
		game.goto_scene("res://scenes/leaderboard.tscn")
	if(player_choice):
		if(up):
			game.is_2_player = false
			animation = "player1_flash" 
			sample_player.play("swing")
		elif(down):
			game.is_2_player = true
			animation = "player2_flash" 
			sample_player.play("swing")
		if(!anim.is_playing()):
			anim.play(animation)
	if(start or (Input.is_action_pressed("punch") and player_choice)):
		sample_player.play("start")
		anim.play("pulse")
		timer.start()
		set_process(false)
