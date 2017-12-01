extends Node2D

onready var timer = get_node("Timer")
onready var area = get_node("Area2D")
onready var spawnpoint_1= get_node("spawnpoint_1")
onready var spawnpoint_2= get_node("spawnpoint_2")

var active = false
var guard = preload("res://scenes/guard.tscn")
var red_guard = preload("res://scenes/red_guard.tscn")
var ninja = preload("res://scenes/ninja.tscn")
var fat_ninja = preload("res://scenes/fat_ninja.tscn")
var green_whig = preload("res://scenes/green_whig.tscn")
var duelist = preload("res://scenes/duelist.tscn")
onready var camera_rig = get_tree().get_root().get_child(2).get_node("camera_rig")

export var type = 0
export var has_door = false
export var number_to_spawn = 10
var total_spawned = 0

func on_arena_area_body_enter(body):
	if body.is_in_group("heroes"):
		active = true
		timer.start()

func _on_timer_timeout():
	if total_spawned >= number_to_spawn:
		self.set_process(false)
		self.queue_free()
	else:
		total_spawned += 1
		var e = guard.instance()
		if(type == 0):
			e = guard.instance()
			if rand_range(1,10) < 2:
				e = red_guard.instance()
		elif(type == 1):
			e = ninja.instance()
		
			if rand_range(1,10) < 2:
				e = fat_ninja.instance()
		else:
			e = green_whig.instance()
			if rand_range(1,10) < 2:
				e = duelist.instance()
				
		if rand_range(1,11) < 5:
			e.set_global_pos(spawnpoint_1.get_global_pos())
		else:
			e.set_global_pos(spawnpoint_2.get_global_pos())
			
		game.current_scene.add_child(e)

func _process(delta):
	if(active):
		camera_rig.can_move = false

func _ready():
	area.connect("body_enter", self, "on_arena_area_body_enter")
	timer.connect("timeout", self, "_on_timer_timeout")
	set_process(true)
