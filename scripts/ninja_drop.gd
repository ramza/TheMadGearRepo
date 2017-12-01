extends Node2D

onready var anim = get_node("AnimationPlayer")
onready var drop_point = get_node("drop_point")
var ninja = preload("res://scenes/ninja.tscn")

func _on_finished():
	var n = ninja.instance()
	n.set_global_pos(drop_point.get_global_pos())
	game.current_scene.add_child(n)
	queue_free()

func _ready():
	anim.connect("finished", self, "_on_finished")