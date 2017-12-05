#game script
extends Node

var cutscenes = [
	"res://scenes/mayor_tied.tscn",
	"res://scenes/big_evil_face.tscn",
	"res://scenes/hideout.tscn",
	"res://scenes/prison_overlook.tscn",
	"res://scenes/behind_bars.tscn",
	"res://scenes/prison_1.tscn",
	"res://scenes/city_1.tscn",
	"res://scenes/graveyard_1.tscn",
	"res://scenes/courtroom_1.tscn",
	"res://scenes/rocket.tscn",
	"res://scenes/fortress_1.tscn",
	"res://scenes/credits.tscn",
	"res://scenes/logo.tscn",
	"res://scenes/final_boss.tscn",
	"res://scenes/prison_intro.tscn",
	"res://scenes/city_intro.tscn",
	"res://scenes/graveyard_intro.tscn",
	"res://scenes/courtroom_intro.tscn",
	"res://scenes/fortress_intro.tscn",
	"res://scenes/prison_intro.tscn",
	"res://scenes/leaderboard.tscn",
]
	
var maps = ["res://scenes/title.tscn",
			"res://scenes/player_select.tscn", 
			"res://scenes/prison_1.tscn",
			"res://scenes/prison_2.tscn",
			"res://scenes/prison_3.tscn",
			"res://scenes/city_1.tscn",
			"res://scenes/city_2.tscn",
			"res://scenes/city_3.tscn",
			"res://scenes/graveyard_1.tscn",
			"res://scenes/graveyard_2.tscn",
			"res://scenes/graveyard_3.tscn",
			"res://scenes/graveyard_4.tscn",
			"res://scenes/courtroom_1.tscn",
			"res://scenes/courtroom_2.tscn",
			"res://scenes/courtroom_3.tscn",
			"res://scenes/fortress_1.tscn",
			"res://scenes/fortress_2.tscn",
			"res://scenes/fortress_3.tscn",
			"res://scenes/fortress_4.tscn",
			"res://scenes/prison_aftermath.tscn",
			"res://scenes/city_aftermath.tscn",
			"res://scenes/graveyard_aftermath.tscn",
			"res://scenes/courtroom_aftermath.tscn",
			"res://scenes/fortress_aftermath.tscn",
			"res://scenes/ending.tscn",
			"res://scenes/prison_4.tscn",
			"res://scenes/courtroom_4.tscn",
			"res://scenes/stage.tscn",
			"res://scenes/prison_cell.tscn"]

# load music files
var prison_song = preload("res://audio/OST/prison_break.ogg")
var spooky_song = preload("res://audio/OST/creepy_crew.ogg")
var theme_song = preload("res://audio/OST/intro.ogg")
var ninja_song = preload("res://audio/OST/ninja.ogg")
var boss_song = preload("res://audio/OST/boss_theme.ogg")
var final_level_song = preload("res://audio/OST/final_level.ogg")
var whig_song = preload("res://audio/OST/whigs.ogg")
var ending_song = preload("res://audio/OST/ending.ogg")
var story_song_1 = preload("res://audio/OST/story_1.ogg")
var story_song_2 = preload("res://audio/OST/story_2.ogg")
var story_song_3 = preload("res://audio/OST/story_3.ogg")

# load playable characters
var shreddy = preload("res://scenes/shreddy.tscn")
var rex = preload("res://scenes/rex.tscn")
var miles = preload("res://scenes/miles.tscn")
var bruce = preload("res://scenes/bruce.tscn")
var bigvig = preload("res://scenes/bigvig.tscn")

var player2
var player2_index = 4
var player
var is_2_player = false
var was_2_player = false
var prev_player_1_index = 0
var player_index = 3

var root
var HUD
var current_scene
var current_scene_path
var last_scene
var camera
var camera_rig
var stream_player
var timer
var enemy_list = []
var character_list = []
var game_over = false

var cutscene_index = 0

var player1_score = 0
var player2_score = 0
var player1_hp = 10
var player2_hp = 10
var player1_mp = 100
var player2_mp = 100

var time_freeze = false
var time_freeze_delay = 0

var slow_counter = 0
var slow_duration = 0

var continues = 3
var player_2_continue = false

var savegame = File.new()
var save_path = "user://savegame.save"
var save_data = {'name_1': "Bonnie", 'score_1': 5000,
				'name_2': "Bruce", 'score_2': 4000,
				'name_3': "Bigvig", 'score_3': 3000,
				'name_4': "Miles", 'score_4': 2000,
				'name_5': "Shreddy", 'score_5': 1000,
				'name_6': "Ramza", 'score_6': 500,
				'name_7': "Rex", 'score_7': 400,
				'name_8': "Dingo", 'score_8': 300,
				'name_9': "Bloop", 'score_9': 200,
				'name_10': "Ursula", 'score_10': 100,}

func _on_timer_timeout():
	if(slow_counter > slow_duration):
		timer.stop()
	else:
		freeze_time(4)
		slow_counter+=1

func slow_time(duration, speed):
	slow_duration = duration
	timer.set_wait_time(speed)
	timer.start()

func freeze_time(delay):
	time_freeze = true
	time_freeze_delay = delay
	get_tree().set_pause(true)

func _ready():
	
	var joysticks = Input.get_connected_joysticks()
	
	if not savegame.file_exists(save_path):
		create_save()

	self.set_pause_mode(2)
	stream_player = global.get_node("StreamPlayer")
	timer = global.get_node("Timer")
	timer.connect("timeout", self, "_on_timer_timeout")
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count()-1)   
	# this part is for debugging, so that we don't have to start at the title screen
	#the final version of the game won't need this part
	if(!current_scene.is_in_group("intros") and !current_scene.is_in_group("cutscenes") and current_scene.get_name() != "game_over" and current_scene.get_name() != "logo" and current_scene.get_name() != "title" and current_scene.get_name() != "player_select" and current_scene.get_name() != "credits"):
        initialize_scene()
	elif(current_scene.is_in_group("title") or current_scene.is_in_group("cutscenes")):
		handle_music()
	current_scene_path = maps[0]
	last_scene = current_scene_path
	
func _process(delta):
	if(time_freeze):
		time_freeze_delay -= 1
		if(time_freeze_delay < 0):
			time_freeze = false
			get_tree().set_pause(false)
	if(character_list.size() > 0 or is_2_player):
		sort_characters_by_y_position()
	
		
#identitfy what scene we're in and play the correct song on the global stream player
func handle_music():
	var stream
	if(current_scene.is_in_group("prison")):
		stream_player.set_volume(1)
		stream = prison_song
	elif(current_scene.is_in_group("graveyard")):
		stream_player.set_volume(1)
		stream  = spooky_song
	elif(current_scene.is_in_group("city")):
		stream_player.set_volume(1)
		stream = ninja_song
	elif(current_scene.is_in_group("title")):
		stream_player.set_volume(1)
		stream = theme_song
	elif(current_scene.is_in_group("boss")):
		stream_player.set_volume(2)
		stream = boss_song
	elif(current_scene.is_in_group("courtroom")):
		stream_player.set_volume(1)
		stream = whig_song
	elif(current_scene.is_in_group("ending")):
		stream_player.set_volume(1)
		stream = ending_song
	elif(current_scene.is_in_group("fortress")):
		stream_player.set_volume(1)
		stream = final_level_song
	elif(current_scene.is_in_group("cutscenes_alt1")):
		stream_player.set_volume(1)
		stream = story_song_3
	elif(current_scene.is_in_group("cutscenes_alt")):
		stream_player.set_volume(1)
		stream = story_song_2
	elif(current_scene.is_in_group("cutscenes")):
		stream_player.set_volume(1)
		stream = story_song_1
	if(stream_player.get_stream() != stream or !stream_player.is_playing()):
		stream_player.set_stream(stream)
		stream_player.play()
	
# we need to synchronize the game manager and the other parts of the level
# such as the HUD, the player, and the enemies. we do this each time we load a level
func initialize_scene():
	enemy_list.clear()
	character_list.clear()
	handle_music()
	assign_player()
	var spawn_position = current_scene.get_node("player_spawn").get_pos()
	player.set_pos(spawn_position)
	player.set_score(player1_score)
	player.hp = player1_hp
	player.mp = player1_mp
	current_scene.add_child(player)
	var temp = player
	character_list.append(player)
	if(is_2_player):
		assign_player2()
		var position = Vector2(spawn_position.x+20, spawn_position.y+10)
		player2.set_pos(position)
		player2.set_score(player2_score)
		player2.hp = player2_hp
		player2.mp = player2_mp
		current_scene.add_child(player2)
		player = temp
		character_list.append(player2)
		print(player.get_name())
		print(player2.get_name())
		
	HUD = current_scene.get_node("HUD")
	HUD.initialize_health_icons()
	camera_rig = current_scene.get_node("camera_rig")
	camera = camera_rig.get_node("Camera2D")
	set_process(true)

#assign the character to the global player property, this is called from
#the player select scene, it provides and index
#TODO make this an enum instead of an int
func assign_player():
	if(player_index == 0):
		player = shreddy.instance()
	elif(player_index == 1):
		player = rex.instance()
	elif(player_index == 2):
		player = bigvig.instance()
	elif(player_index == 3):
		player = bruce.instance()
	elif(player_index == 4):
		player = miles.instance()
		
func assign_player2():
	if(player2_index == 0):
		player2 = shreddy.instance()
	elif(player2_index == 1):
		player2 = rex.instance()
	elif(player2_index == 2):
		player2 = bigvig.instance()
	elif(player2_index == 3):
		player2 = bruce.instance()
	elif(player2_index == 4):
		player2 = miles.instance()
	player2.set_single_player(false)
#delayd goto scene so that we give godot the chance to clean up
func goto_scene(path):
    call_deferred("_deferred_goto_scene",path)

# the enemy list is used to manager our guards
# TODO make an enemy manager class 
func add_to_enemy_list(enemy):
	enemy_list.append(enemy)
	character_list.append(enemy)
	
func remove_from_enemy_list(enemy):
	enemy_list.erase(enemy)
	character_list.erase(enemy)
	if(enemy_list.size() == 0):
		camera_rig.can_move = true
		
func add_to_character_list(c):
	character_list.append(c)

func remove_from_character_list(c):
	character_list.remove(character_list.find(c))

# loop through all the enemies and assign them a different z depth
# in order of the y position on screen, lowest to highest

func sort_characters_by_y_position():
	var swapped = true
	while(swapped):
		swapped = false
		for i in range(character_list.size()-1):
			if (character_list[i].standing_pos > character_list[i+1].standing_pos):
				swapped = true
				var e = character_list[i]
				character_list[i] = character_list[i+1]
				character_list[i+1] = e
				
	# set the z limit to the list length
	
	for i in range(character_list.size()):
		character_list[i].set_z(i+1)
	
func _deferred_goto_scene(path):
    set_process(false)
    time_freeze = false
    current_scene_path = path
    # Immediately free the current scene,
    # there is no risk here.
    current_scene.free()

    # Load new scene
    var s = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = s.instance()
    # Add it to the active scene, as child of root
    get_tree().get_root().add_child(current_scene)

    # optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene( current_scene )
    
    var scene_name = current_scene.get_name()
    if(!current_scene.is_in_group("intros") and !current_scene.is_in_group("cutscenes") and scene_name != "game_over" and scene_name != "logo" and scene_name != "title" and scene_name != "player_select" and scene_name != "credits"):
        initialize_scene()
    else:
        handle_music()
        player1_hp = 10
        player2_hp = 10

func create_save():
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()
	
func save():
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()
	
func read_savegame():
	savegame.open(save_path, File.READ)
	save_data = savegame.get_var()
	savegame.close()
	