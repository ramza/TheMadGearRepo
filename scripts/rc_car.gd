extends KinematicBody2D

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var particles = get_node("Particles2D")
onready var area = get_node("Area2D")

export var rc_car = false

var active = true
export var spin = false

export var group_name = "heroes"

var explosion = preload("res://scenes/small_explosion.tscn")
var enemy_punch = preload("res://scenes/enemy_punch.tscn")
var hero_punch = preload("res://scenes/hero_punch.tscn")
onready var attack_position = get_node("attack_position")
var explosion_shape
var is_player_one = true
var punch
var feet_mod = 0
var damage = 1
export var explode_off_screen = true

export var motion_start = Vector2(-1, 0)
export var SPEED = 100

func _on_timer_timeout():

	game.remove_from_enemy_list(self)
	set_process(false)
	queue_free()
	
func extended_behavior():
	punch = enemy_punch.instance()
	punch.damage = damage

func _ready():
	explosion_shape = get_node("explosion_shape").get_shape()
	#area.connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	extended_behavior()
	set_process(true)
		
	if(spin):
		set_rot(rand_range(0,360))

	
func set_player_one(value):
	is_player_one = value

func _on_body_enter(body):
	if ((body.is_in_group("heroes")and rc_car) or body.is_in_group("enemies") or body.get_name() == "Tilemap"):
		explode()
	
func explode():
	if(active):
		active = false
		timer.start()
		get_node("Sprite").set_hidden(true)
		sample_player.play("explode")
		var e = explosion.instance()
		e.set_global_pos(get_global_pos())
		game.current_scene.add_child(e)
		var e_punch = hero_punch.instance()
		e_punch.set_type("special")
		e_punch.set_global_pos(attack_position.get_global_pos())
		e_punch.set_scale(get_scale())
		e_punch.set_shape(0,explosion_shape)
		if(is_player_one and !rc_car):
			e_punch.set_player_one(true)
		elif !rc_car:
			e_punch.set_player_one(false)
		game.current_scene.add_child(e_punch)

		particles.set_hidden(true)
		
		game.camera.shake(1,10,2)
		
func take_damage():
	explode()
	
func _process(delta):
	var motion = motion_start
	motion = motion*SPEED*delta
	move(motion)
	
	detect_collision()
	if(explode_off_screen and get_global_pos().x - game.camera.get_global_pos().x < 0):
		game.remove_from_enemy_list(self)
		queue_free()

func detect_collision():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if((body.is_in_group("heroes")and rc_car) or body.is_in_group("enemies")):
			explode()
			set_process(false)
	