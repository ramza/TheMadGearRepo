extends RigidBody2D
onready var timer = get_node("Timer")

func _on_timer_timeout():
	queue_free()

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
