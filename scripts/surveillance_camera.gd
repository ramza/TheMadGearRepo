extends StaticBody2D

const STATES = {
	"LEFT": 0,
	"RIGHT":1,
	"MIDDLE":2,
	"FALL":3,
	"DEATH":4
}

var state
var hp = 7
onready var timer = get_node("Timer")
onready var death_timer = get_node("death_timer")
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var laser_canon = get_node("laser_canon")
onready var area = get_node("Area2D")

var explosion = preload("res://scenes/small_explosion.tscn")
var laser = preload("res://scenes/laser.tscn")
var player 
var max_distance = 40

func _ready():
	death_timer.connect("timeout", self, "_on_death_timer_timeout")
	area.connect("body_enter", self, "_on_area_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")

func _on_death_timer_timeout():
	queue_free()

func _on_timer_timeout():
	sample_player.play("laser")
	var lzr = laser.instance()
	lzr.set_global_pos(laser_canon.get_global_pos())
	if(state == STATES.LEFT):
		lzr.velocity = Vector2(-1,1)
		lzr.get_node("AnimationPlayer").play("left")
	elif(state == STATES.RIGHT):
		lzr.velocity = Vector2(1,1)
		lzr.get_node("AnimationPlayer").play("right")
	else:
		lzr.get_node("AnimationPlayer").play("middle")
	game.current_scene.add_child(lzr)

func _on_area_body_enter(body):
	if(body.is_in_group("heroes")):
		player = body
		timer.start()
		set_process(true)
	
func take_damage(damage, type):
	hp -= damage
	if(state != STATES.DEATH and hp <= 0):
		state = STATES.DEATH
		timer.stop()
		get_node("Sprite").set_hidden(true)
		sample_player.play("explode")
		var e = explosion.instance()
		e.set_global_pos(get_global_pos())
		game.current_scene.add_child(e)
		death_timer.start()
		set_process(false)
		get_node("CollisionShape2D").set_trigger(true)
	
func _process(delta):
	if(!game.is_2_player):
		player = game.player
	if(player.get_pos().x - self.get_pos().x > 300):
		queue_free()
	if(self.get_pos().x - player.get_pos().x > max_distance):
		state = STATES.LEFT
	elif(player.get_pos().x - get_pos().x > max_distance):
		state = STATES.RIGHT
	else:
		state = STATES.MIDDLE
		
	var animationName = ""
	if(state == STATES.LEFT):
		animationName = "left"
	elif(state == STATES.RIGHT):
		animationName = "right"
	else:
		animationName = "middle"
	
	anim.play(animationName)
