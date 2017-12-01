extends Area2D

onready var timer = get_node("Timer")

var guard = preload("res://scenes/guard.tscn")
var ninja = preload("res://scenes/ninja.tscn")
var hellhound = preload("res://scenes/hellhound.tscn")
var big_dude = preload("res://scenes/big_dude.tscn")
var rc = preload("res://scenes/rc_car.tscn")
var red_guard = preload("res://scenes/red_guard.tscn")
var skeleton = preload("res://scenes/skeleton.tscn")
var fat_ninja = preload("res://scenes/fat_ninja.tscn")
var brawler = preload("res://scenes/brawler.tscn")
var archer = preload("res://scenes/archer.tscn")
var super_ninja = preload("res://scenes/super_ninja.tscn")
var boss_bot = preload("res://scenes/boss_bot.tscn")
var death = preload("res://scenes/death.tscn")
var cyborg = preload("res://scenes/cyborg.tscn")
var vampire = preload("res://scenes/vampire.tscn")
var green_whig = preload("res://scenes/green_whig.tscn")
var duelist = preload("res://scenes/duelist.tscn")
var big_whig = preload("res://scenes/big_whig.tscn")
var waltzer = preload("res://scenes/waltzer.tscn")
var red_skeleton = preload("res://scenes/red_skeleton.tscn")

#how  many of each type of enemy
export var guards = true
export var ninjas = false
export var hounds = false
export var big_dudes = false
export var rc_car = false
export var red_guards = false
export var skeletons = false
export var fat_ninjas = false
export var brawlers = false
export var archers = false
export var super_ninjas = false
export var boss_bots = false
export var deaths = false
export var cyborgs = false
export var vampires = false
export var green_whigs = false
export var duelists = false
export var big_whigs = false
export var waltzers = false
export var red_skeletons = false

export var amount = 2
export var has_door = false

var is_active = true

func _on_body_enter(body):
	#if character has entered the activation area and we haven't spawned
	if(is_active and body.is_in_group("heroes")):
		is_active = false
		if(has_door):
			#this option will opne a portal door
			var door = get_node("door")
			door.get_node("AnimationPlayer").play("open")
			door.is_open = true
			
		game.camera_rig.can_move = false
		spawn_enemies()
		if(!has_door):
			queue_free()

func _ready():

	connect("body_enter", self, "_on_body_enter")
	
func spawn_enemies():
	#for each guard, set the spawn position in order of 1, 2, 3
	var enemy_type = null
	if(guards):
		enemy_type = guard
	elif(ninjas):
		enemy_type = ninja
	elif(hounds):
		enemy_type = hellhound
	elif(big_dudes):
		enemy_type = big_dude
	elif(rc_car):
		enemy_type = rc
	elif(red_guards):
		enemy_type = red_guard
	elif(skeletons):
		enemy_type = skeleton
	elif(fat_ninjas):
		enemy_type = fat_ninja
	elif(brawlers):
		enemy_type = brawler
	elif(archers):
		enemy_type = archer
	elif(super_ninjas):
		enemy_type = super_ninja
	elif(boss_bots):
		enemy_type = boss_bot
	elif(deaths):
		enemy_type = death
	elif(cyborgs):
		enemy_type = cyborg
	elif(vampires):
		enemy_type = vampire
	elif(green_whigs):
		enemy_type  = green_whig
	elif(duelists):
		enemy_type = duelist
	elif(big_whigs):
		enemy_type = big_whig
	elif(waltzers):
		enemy_type = waltzer
	elif(red_skeletons):
		enemy_type = red_skeleton
		
	if(enemy_type != null):
		for i in range(amount):
			var enemy = enemy_type.instance()
			var spawn_position
			if(i == 0):
				spawn_position = get_node("spawn_point1").get_global_pos()
			elif(i == 1 ):
				spawn_position = get_node("spawn_point2").get_global_pos()
			elif(i == 2):
				spawn_position = get_node("spawn_point3").get_global_pos()
			elif(i == 3):
				spawn_position = get_node("spawn_point4").get_global_pos()
			elif(i == 4):
				spawn_position = get_node("spawn_point5").get_global_pos()
			enemy.set_pos(Vector2(spawn_position.x,spawn_position.y-enemy.feet_mod))
			game.current_scene.add_child(enemy)