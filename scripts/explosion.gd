extends Sprite

onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")

export var audio_name = "big_explosion"

func _on_timer_timeout():
	queue_free()

func _ready():
	sample_player.play("explode")
	timer.connect("timeout", self, "_on_timer_timeout")
	sample_player.play(audio_name)
	timer.start()
	pass
