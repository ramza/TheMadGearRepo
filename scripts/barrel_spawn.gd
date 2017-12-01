extends Node2D

onready var area = get_node("Area2D")
onready var spawnpoint = get_node("spawnpoint")
var barrel = preload("res://scenes/barrel.tscn")

func _on_body_enter(body):
	if body.is_in_group("heroes"):
		var b = barrel.instance()
		b.set_global_pos(spawnpoint.get_global_pos())
		game.current_scene.add_child(b)
		queue_free()

func _ready():
	area.connect("body_enter", self, "_on_body_enter")
