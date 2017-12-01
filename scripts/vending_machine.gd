extends KinematicBody2D

const STATES = {
   "IDLE": 0,
   "DAMAGE1": 1,
   "DAMAGE2": 2,
   "DAMAGE3": 3,
   "DAMAGE4": 4,
   "DAMAGE5": 5
}
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")

var active = true
var explosion = preload("res://scenes/big_explosion_2.tscn")
var burger = preload("res://scenes/burger.tscn")
var pizza_slice = preload("res://scenes/pizza_slice.tscn")
var pizza_full = preload("res://scenes/pizza_full.tscn")
var chicken = preload("res://scenes/chicken.tscn")
var coin = preload("res://scenes/gold_coin.tscn")
var state
var prev_state
export var hp = 6
export var drop_coin = false
export var drop_spread = 20

func take_damage(damage, type):
	if(active):
		hp -= damage
		game.camera.shake(1,7,1)
		sample_player.play("hurt")
		if(hp < 1):
			timer.start()
			var e = explosion.instance()
			sample_player.play("explode")
			e.set_global_pos(get_global_pos())
			game.current_scene.add_child(e)
			
			var b
			var rand = int(rand_range(0,2))
			if(drop_coin):
				b = coin.instance()
			elif(rand == 1):
				b = burger.instance()
			else:
				b = pizza_slice.instance()
			var pos = Vector2(get_global_pos().x, get_global_pos().y + drop_spread)
			b.set_z(get_z())
			b.set_global_pos(pos)
			game.current_scene.add_child(b)
			get_node("Sprite").set_hidden(true)
			active = false
		elif(hp < 2):
			state = STATES.DAMAGE5
		elif(hp < 3):
			state = STATES.DAMAGE4
		elif(hp < 4):
			state = STATES.DAMAGE3
		elif(hp < 5):
			state = STATES.DAMAGE2
		elif(hp < 6):
			state = STATES.DAMAGE1

	

func _process(delta):
	var animationName
	if(state == STATES.IDLE):
		animationName = "idle"
	elif(state == STATES.DAMAGE1):
		animationName = "damage1"
	elif(state == STATES.DAMAGE2):
		animationName = "damage2"
	elif(state == STATES.DAMAGE3):
		animationName = "damage3"
	elif(state == STATES.DAMAGE4):
		animationName = "damage4"
	elif(state == STATES.DAMAGE5):
		animationName = "damage5"
	
	if(!anim.is_playing() or
	(state == STATES.DAMAGE1 and prev_state != STATES.DAMAGE1)):
		anim.play(animationName)
		
	prev_state = state

func _on_timer_timeout():
	queue_free()
	
func _ready():
	state = STATES.IDLE
	prev_state = state
	set_process(true)
	timer.connect("timeout", self, "_on_timer_timeout")
	# Called every time the node is added to the scene.
	# Initialization here
	pass
