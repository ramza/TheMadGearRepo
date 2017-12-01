# HUD script
extends CanvasLayer

onready var reset_timer = get_node("reset_timer")
onready var p1_score = get_node("p1_score")
onready var p2_score = get_node("p2_center").get_node("p2_score")
onready var p2 = get_node("p2_center").get_node("p2_health")
onready var p2_special_bar = get_node("p2_center").get_node("p2_special_bar")
onready var p1 = get_node("p1_health")
onready var special_bar = get_node("special_bar")
onready var anim = get_node("AnimationPlayer")
onready var black_screen = get_node("black_screen")
onready var pause = get_node("pause_label")
onready var timer = get_node("Timer")
onready var acts = get_node("acts")
onready var game_time = get_node("game_time")
onready var game_timer = get_node("game_timer")
onready var restart_btn = get_node("restart_btn")
onready var volume_control = get_node("volume_control")
onready var fullscreen = get_node("fullscreen_box")
onready var panel = get_node("Panel")

var time = 0
var can_input = false
var is_paused = false
var health_icon = preload("res://scenes/health_icon.tscn")

var p1_health_icons = []
var p2_health_icons = []
var boss_health_icons = []
var red = 0
var colorswitch = false
var lastColor = Color(0,0,255)

var boss
var scene_start = true

var colorTimer = 5
var colorTimeCounter = 0

func get_color(amount):
	var color = lastColor
	if colorTimeCounter > colorTimer:
		colorTimeCounter = 0
		color = Color(255,255,255)
	if(amount < 0.25):
		color = Color(255,0,0)
	elif(amount < 0.5):
		color = Color(255,215,0)
	elif(amount < 0.65):
		color = Color(0,255,0)
	elif(amount < 0.80):
		color = Color(0,150,200)
	else:
		colorTimeCounter+=1
	return color

func update_special_bar(amount):
	special_bar.set_scale(Vector2(amount, 1))
	var color = get_color(amount)
	special_bar.set_modulate(color)
	special_bar.show()

func update_player2_special_bar(amount):
	p2_special_bar.set_scale(Vector2(amount, 1))
	var color = get_color(amount)
	p2_special_bar.set_modulate(color)
	p2_special_bar.show()
	
#type must be the name of an animation in the HUD animation player
func play_fade(type):
	anim.play(type)
	
func update_player1_score(score):
	p1_score.set_text(str(score))
	
func update_player2_score(score):
	p2_score.set_text(str(score))
	
func initialize_boss(hp):
	var pos = get_node("boss_center").get_node("health")
	for i in range(hp):
		var icon = health_icon.instance()
		icon.set_modulate(Color(100,0,255))
		boss_health_icons.append(icon)
		icon.set_global_pos(Vector2(pos.get_global_pos().x + (i*2), pos.get_global_pos().y))
		add_child(icon)
	get_node("boss_center").show()

func initialize_health_icons():
	p1 = get_node("p1_health")
	for i in range(game.player.max_hp):
		var icon = health_icon.instance()
		p1_health_icons.append(icon)
		icon.set_pos(Vector2(p1.get_pos().x + (i*4), p1.get_pos().y))
		add_child(icon)
		
	if(game.is_2_player):
		p2 = get_node("p2_center").get_node("p2_health")
		for i in range(game.player2.max_hp):
			var icon = health_icon.instance()
			p2_health_icons.append(icon)
			icon.set_pos(Vector2(p2.get_global_pos().x + (i*4), p2.get_global_pos().y))
			add_child(icon)
			
	update_player_one_health(game.player.hp)
	if(game.is_2_player):
		update_player_two_health(game.player2.hp)

func update_boss_health_icons(hp):
	for i in boss_health_icons:
		i.hide()
	for i in range(hp):
		boss_health_icons[i].show()

func update_player_one_health(var hp):
	for i in p1_health_icons:
		i.set_hidden(true)
	for i in range(hp):
		p1_health_icons[i].set_hidden(false)
		
func update_player_two_health(var hp):
	for i in p2_health_icons:
		i.set_hidden(true)
	for i in range(hp):
		p2_health_icons[i].set_hidden(false)
		
		
func _on_reset_timer_timeout():
	if(game.game_over):
		game.last_scene = game.current_scene_path
		game.goto_scene("res://scenes/game_over.tscn")
	else:
		game.goto_scene(game.current_scene_path)
	
func _on_game_timer_timeout():
	if(!is_paused):
		time += 1
		var minute = time/60
		var second = time%60
		if(minute < 10):
			minute = "0" + str(minute)
		else:
			minute = str(minute)
		if(second < 10):
			second = "0" + str(second)
		else:
			second = str(second)
		game_time.set_text(minute + ":" + second)
	
func _on_timer_timeout():
	can_input = true
	timer.set_wait_time(0.5)
	timer.stop()
	if scene_start:
		scene_start = false
		get_tree().set_pause(false)

func _on_restart_btn_down():
	get_tree().set_pause(false)
	game.goto_scene(game.maps[0])

func _on_music_volume_changed(val):
	AudioServer.set_stream_global_volume_scale(val)
	
func _on_fx_volume_changed(val):
	AudioServer.set_fx_global_volume_scale(val)
	
func _on_fullscreen_down():
	fullscreen.update()
	OS.set_window_fullscreen(fullscreen.is_pressed())

func _ready():
	if(game.current_scene.is_in_group("prison")):
		acts.set_text("Act I - The Prison")
	elif(game.current_scene.is_in_group("city")):
		acts.set_text("Act II - The City")
	elif(game.current_scene.is_in_group("graveyard")):
		acts.set_text("Act III - The Graveyard")
	elif(game.current_scene.is_in_group("courtroom")):
		acts.set_text("Act IV- The Court")
	elif(game.current_scene.is_in_group("fortress")):
		acts.set_text("Act V - The Moon Base")
	elif(game.current_scene.is_in_group("boss")):
		acts.set_text("")
		
	if(game.is_2_player):
		get_node("p2_center").set_hidden(false)
		update_player2_score(game.player2_score)
	update_player1_score(game.player1_score)
	reset_timer.connect("timeout", self, "_on_reset_timer_timeout")
	black_screen.set_hidden(false)
	play_fade("fade_in")
	volume_control.get_node("music_slider").connect("value_changed",self,"_on_music_volume_changed")
	volume_control.get_node("fx_slider").connect("value_changed",self,"_on_fx_volume_changed")
	volume_control.hide()
	timer.connect("timeout", self, "_on_timer_timeout")
	game_timer.connect("timeout", self, "_on_game_timer_timeout")
	restart_btn.connect("button_down", self, "_on_restart_btn_down")
	fullscreen.connect("pressed", self, "_on_fullscreen_down")
	special_bar.hide()
	p2_special_bar.hide()
	restart_btn.hide()
	fullscreen.hide()
	panel.hide()
	timer.set_wait_time(1)
	timer.start()
	get_tree().set_pause(true)
	set_process(true)
	
func _process(delta):
	if((!game.player.was_player_2 and (Input.is_joy_button_pressed(0,11) or Input.is_key_pressed(KEY_RETURN)) and can_input) or
		( game.player.was_player_2 and Input.is_action_pressed("p2_start") and can_input)):
		if(!is_paused):
			is_paused = true
			get_tree().set_pause(true)
			pause.show()
			can_input = false
			timer.start()
			restart_btn.show()
			volume_control.show()
			fullscreen.show()
			panel.show()
		else:
			panel.hide()
			volume_control.hide()
			restart_btn.hide()
			fullscreen.hide()
			is_paused = false
			get_tree().set_pause(false)
			pause.hide()
			can_input = false
			timer.start()