extends Node2D

onready var anim = get_node("AnimationPlayer")

func _on_anim_finished():
	queue_free()
	
func _ready():
	anim.connect("finished", self, "_on_anim_finished")
