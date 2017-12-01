extends Node2D

onready var sample_player = get_node("SamplePlayer")
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var continue_label = get_node("continue_label")
onready var quit_label = get_node("quit_label")
onready var action_timer = get_node("action_timer")
onready var pointer = get_node("pointer")

var active = true
var can_choose = true
var quit = false

func _on_timer_timeout():
	if(quit):
		game.goto_scene("res://scenes/leaderboard.tscn")
	else:
		game.player1_score = 0
		game.player2_score = 0
		if game.player_2_continue:
			game.is_2_player = true
			game.was_2_player = false
			game.player_index = game.prev_player_1_index
		game.goto_scene(game.last_scene)
	pass

func _on_action_timer_timeout():
	can_choose = true

func _process(delta):
	var start = Input.is_action_pressed("start") or Input.is_action_pressed("punch")
	
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	if(can_choose):
		if(up):
			quit = false
			pointer.set_pos(Vector2(continue_label.get_pos().x-10,continue_label.get_pos().y+5))
			can_choose=false
			action_timer.start()
			sample_player.play("start")
		elif(down):
			quit = true
			pointer.set_pos(Vector2(quit_label.get_pos().x-10,quit_label.get_pos().y+5))
			can_choose=false
			action_timer.start()
			sample_player.play("start")
		
	if(start and active):
		if(!quit and game.continues > 0):
			game.continues -= 1
			continue_label.set_text("continue "+str(game.continues))
			can_choose = false
			active = false
			timer.start()
			sample_player.play("start")
		elif(!quit and game.continues<=0):
			pass
		else:
			can_choose = false
			active = false
			timer.start()
			sample_player.play("start")

func _ready():
	pointer.set_pos(Vector2(continue_label.get_pos().x-10,continue_label.get_pos().y+5))
	action_timer.connect("timeout", self, "_on_action_timer_timeout")
	timer.connect("timeout", self, "_on_timer_timeout")
	continue_label.set_text("continue "+str(game.continues))
	set_process(true)
