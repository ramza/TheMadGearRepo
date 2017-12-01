extends KinematicBody2D

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var attack_timer = get_node("attack_timer")
onready var static_body = get_node("StaticBody2D")
onready var sample_player = get_node("SamplePlayer2D")

var standing_pos
var hero_punch = preload("res://scenes/hero_punch.tscn")
var explosion = preload("res://scenes/small_explosion.tscn")

var active = false
var direction = 1
var speed = 200

func take_damage(dir):
	if(!active):
		sample_player.play("metal")
		direction = dir
		set_scale(Vector2(direction, 1))
		static_body.queue_free()
		active = true
		timer.start()
		attack_timer.start()
		anim.play("flying")
		set_process(true)

func _process(delta):
	if is_colliding():
		var col = get_collider()
		if col.get_name() == "TileMap":
			death()
		
	if(active):
		var velocity = Vector2(direction, 0)
		var motion = velocity * delta * speed
		motion = move(motion)
		
func _on_attack_timer_timeout():
	var punch = hero_punch.instance()
	punch.set_global_pos(Vector2(get_global_pos().x+20, get_global_pos().y-12))
	punch.set_type("special")
	game.current_scene.add_child(punch)
		
func _on_timer_timeout():
	death()
	
func death():
	var e = explosion.instance()
	e.set_global_pos(get_global_pos())
	game.current_scene.add_child(e)
	game.remove_from_character_list(self)
	self.queue_free()
		

func _ready():
	standing_pos = get_pos().y + 8
	game.add_to_character_list(self)
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	timer.connect("timeout", self, "_on_timer_timeout")