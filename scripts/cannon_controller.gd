extends Node2D

onready var spawn_area = get_node("spawn_area")
onready var spawnpoint = get_node("spawnpoint")

var cannon = preload("res://scenes/cannon.tscn")

func _on_body_enter(body):
	if(body.is_in_group("heroes")):
		var c = cannon.instance()
		c.set_global_pos(spawnpoint.get_global_pos())
		game.current_scene.add_child(c)
		self.queue_free()

func _ready():
	spawn_area.connect("body_enter", self, "_on_body_enter")
	pass
