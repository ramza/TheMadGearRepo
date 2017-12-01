extends Node2D

onready var score_list = get_node("score_list")
onready var names_list = get_node("names_list")
onready var enter_name = get_node("enter_name")
onready var enter_name_label = get_node("enter_name_label")
onready var player1_score = get_node("player1_score")
onready var player2_score = get_node("player2_score")
onready var submit_btn = get_node("submit_btn")
onready var timer = get_node("Timer")
onready var press_start = get_node("press_start")

var active = true
var get_player2 = false
var player1_rank = 11
var player2_rank = 12
var all_done = false

func _on_timer_timeout():
	timer.stop()
	if(all_done):
		game.goto_scene(game.cutscenes[12])
	#active = true

func _process(delta):
	if(!all_done and active and Input.is_action_pressed("start")):
		active = false
		timer.start()
		press_start.get_node("SamplePlayer2D").play("start")
		press_start.hide()
		handle_player_scores()
	elif(active and all_done and Input.is_action_pressed("start")):
		active = false
		press_start.get_node("SamplePlayer2D").play("start")
		timer.set_wait_time(3)
		timer.start()
		press_start.get_node("AnimationPlayer").play("select")

func _on_button_down():
	enter_name.hide()
	enter_name_label.hide()
	submit_btn.hide()
	var player_name = enter_name.get_text()
	if(get_player2):
		cascade_scores(player2_rank)
		game.save_data['name_'+str(player2_rank)] = player_name
		game.save_data['score_'+str(player2_rank)] = game.player2_score
		game.save()
		update_highscores()
		set_all_done()
	else:
		cascade_scores(player1_rank)
		game.save_data['name_'+str(player1_rank)] = player_name
		game.save_data['score_'+str(player1_rank)] = game.player1_score
		game.save()
		update_highscores()
		handle_player_2_score()
	
func handle_player_2_score():
	var rank = get_score_rank(game.player2_score)
	if rank < 11:
		player2_rank = rank
		get_player2 = true
		enter_name.show()
		enter_name_label.set_text("P2 name?")
		enter_name_label.show()
		submit_btn.show()
	else:
		set_all_done()
		
		
func set_all_done():
	press_start.show()
	all_done = true
	active = true

func _ready():
	game.read_savegame()
	submit_btn.connect("button_down", self, "_on_button_down")
	timer.connect("timeout", self, "_on_timer_timeout")
	enter_name.hide()
	player1_score.set_text("Player 1: " +str(game.player1_score))
	player2_score.set_text("Player 2: " +str(game.player2_score))
	enter_name.hide()
	enter_name_label.hide()
	submit_btn.hide()
	if(game.is_2_player):
		player2_score.show()
	else:
		player2_score.hide()

	update_highscores()
	
	set_process(true)

func update_highscores():
	var scores = ""
	var names = ""
	for i in range(0,10,1):
		if i < 9:
			names+= " "
		names += str(i+1) + " " + game.save_data['name_'+str(i+1)] + "\n"
		scores += str(game.save_data['score_'+str(i+1)]) + "\n"
	score_list.set_text(scores)
	names_list.set_text(names)
	
func get_score_rank(score):
	for i in range(0,10,1):
		var s = game.save_data['score_'+str(i+1)]
		if score > s:
			return i+1
	return 11
	
func cascade_scores(rank):
	for i in range(10,rank,-1):
		game.save_data['name_'+str(i)] = game.save_data['name_'+str(i-1)]
		game.save_data['score_'+str(i)] = game.save_data['score_'+str(i-1)]
		
		
func handle_player_scores():
	var rank = get_score_rank(game.player1_score)
	if rank < 11:
		player1_rank = rank
		enter_name.show()
		enter_name_label.set_text("P1 name?")
		enter_name_label.show()
		submit_btn.show()
	else:
		handle_player_2_score()
		
		
	