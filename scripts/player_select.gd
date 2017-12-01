extends Node2D

onready var selection_box = get_node("selection_box")
onready var selection_box2 = get_node("selection_box2")
onready var sample_player = get_node("SamplePlayer2D")
onready var shreddy = get_node("shreddy")
onready var rex = get_node("rex")
onready var big = get_node("big")
onready var bruce = get_node("bruce")
onready var miles = get_node("miles")
onready var action_timer = get_node("action_timer")
onready var p2_action_timer = get_node("p2_action_timer")

var index = 0
var can_act = true
var done = false

var index2 = 1
var p2_can_act = true
var p2_done = false


func _on_timer_timeout():
	can_act = true
	if((done and !game.is_2_player) or (done and game.is_2_player and p2_done)):
		game.goto_scene(game.cutscenes[2])
	action_timer.stop()
		
func _on_p2_timer_timeout():
	p2_can_act = true
	if(done and p2_done):
		game.goto_scene(game.cutscenes[2])
	p2_action_timer.stop()
	
func _ready():
	if(game.is_2_player):
		selection_box2.set_hidden(false)
		game.player_2_continue = true
	action_timer.connect("timeout", self, "_on_timer_timeout")
	p2_action_timer.connect("timeout", self, "_on_p2_timer_timeout")
	set_process(true)
	
func _process(delta):
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var select = Input.is_action_pressed("punch") or Input.is_action_pressed("start")
	
	var back = Input.is_action_pressed("back")
	
	var p2_left = Input.is_action_pressed("p2_move_left")
	var p2_right = Input.is_action_pressed("p2_move_right")
	var p2_select = Input.is_action_pressed("p2_punch") or Input.is_action_pressed("p2_start")
	if(!done):
		if(back):
			game.goto_scene(game.maps[0])
			game.is_2_player = false
			
		if(select):
			game.player_index = index
			sample_player.play("select")
			done = true
			action_timer.set_wait_time(1)
			action_timer.start()
			
		if (left and can_act):
			sample_player.play("blip")
			can_act = false
			action_timer.start()
			index -= 1
			if(index == index2 and game.is_2_player):
				index -= 1
			if (index < 0):
				index = 4
				if(index == index2 and game.is_2_player):
					index -= 1
				
		elif(right and can_act):
			sample_player.play("blip")
			can_act = false
			action_timer.start()
			index += 1
			if(index == index2 and game.is_2_player):
				index += 1
			if(index > 4):
				index = 0
				if(index == index2 and game.is_2_player):
					index += 1
				
		if(index == 0):
			selection_box.set_pos(shreddy.get_pos())
		elif(index == 1):
			selection_box.set_pos(rex.get_pos())
		elif(index == 2):
			selection_box.set_pos(big.get_pos())
		elif(index == 3):
			selection_box.set_pos(bruce.get_pos())
		elif(index == 4):
			selection_box.set_pos(miles.get_pos())
	
	if(!p2_done):
		if(p2_select):
			game.player2_index = index2
			sample_player.play("select")
			p2_done = true
			p2_action_timer.set_wait_time(1)
			p2_action_timer.start()
			
		if (p2_left and p2_can_act):
			sample_player.play("blip")
			p2_can_act = false
			p2_action_timer.start()
			index2 -= 1
			if(index2 == index):
				index2 -= 1
			if (index2 < 0):
				index2 = 4
				if(index2 == index):
					index2 -= 1
		elif(p2_right and p2_can_act):
			sample_player.play("blip")
			p2_can_act = false
			p2_action_timer.start()
			index2 += 1
			if(index2 == index):
				index2 += 1
			if(index2 > 4):
				index2 = 0
				if(index2 == index):
					index2 += 1
				
		if(index2 == 0):
			selection_box2.set_pos(shreddy.get_pos())
		elif(index2 == 1):
			selection_box2.set_pos(rex.get_pos())
		elif(index2 == 2):
			selection_box2.set_pos(big.get_pos())
		elif(index2 == 3):
			selection_box2.set_pos(bruce.get_pos())
		elif(index2 == 4):
			selection_box2.set_pos(miles.get_pos())
