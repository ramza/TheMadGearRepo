extends Sprite

onready var area = get_node("Area2D")
onready var timer = get_node("Timer")
export var map_index = 1
export var is_open = false
var active = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "_on_door_timer_timeout")
	area.connect("body_enter", self, "_on_door_body_enter")
	
func _on_door_timer_timeout():
    game.player1_score = game.player.get_score()
    game.player1_hp = game.player.hp
    game.player1_mp = game.player.mp
    if(game.is_2_player):
        game.player2_score = game.player2.get_score()
        game.player2_hp = game.player2.hp
        game.player2_mp = game.player2.mp
    game.goto_scene(game.maps[map_index])

func _on_door_body_enter(body):
	if (active and is_open and body.is_in_group("heroes") and game.enemy_list.size() == 0):
		game.HUD.play_fade("fade_out")
		active = false
		game.player.disable()
		if(game.is_2_player):
			game.player2.disable()
		timer.start()