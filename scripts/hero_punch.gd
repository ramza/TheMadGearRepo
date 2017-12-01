extends Area2D

var damage = 1
var type = "punch"
var active = true 
var enemies_hurt = []
var is_player_one = true
var has_comboed = false
var is_spikes = false

onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")

var particles

func set_type(t):
	type = t
	if(type == "kick"):
		damage = 2
	elif(type == "special"):
		damage = 4
	elif(type == "bat"):
		damage = 3
	elif(type == "super_punch"):
		damage = 4
		particles = get_node("Particles2D")
	elif(type == "super_kick"):
		damage = 4
		particles = get_node("Particles2D")
	
func extended_behavior():
	pass

func set_player_one(value):
	is_player_one = value

func is_damaged(body):
	for i in range(enemies_hurt.size()):
		if body == enemies_hurt[i]:
			return true
	return false
	
func _on_body_enter(body):
	if(active and body.is_in_group("enemies")):
		if ( !is_damaged(body)):
			enemies_hurt.append(body)
		
		if(body.state != body.STATES.FALL and body.state != body.STATES.DEATH):
			get_node("Sprite").set_hidden(false)
			
			if(type == "special"):
				if(is_player_one):
					game.player.update_score(5)
				else:
					game.player2.update_score(5)
		
		if((type == "punch" or type == "kick" or type == "bat" or type=="super_kick" or type == "super_punch") and body.state != body.STATES.FALL and body.state != body.STATES.DEATH):
		
			if(type == "bat"):
				if(is_player_one):
					game.player.bat_hit_counter += 1
				else:
					game.player2.bat_hit_counter += 1
			if(type == "punch"):
				var r = rand_range(0,2)
				if(r == 0):
					sample_player.play("punch1")
				else:
					sample_player.play("punch2")
			else:
				sample_player.play("punch3")
			
			get_node("Sprite").set_rot(rand_range(0, 360))
			#active = false
			if(!is_spikes):
				var value = 1
				
				if(is_player_one):
					game.player.punch_counter += 1
					game.player.update_score(value)
				else:
					game.player2.punch_counter += 1
					game.player2.update_score(value)
		body.take_damage(damage, type)
		
		if(!game.camera.is_shaking):
			game.camera.shake(0.5,7,0.5)
	elif(active and body.is_in_group("breakables")):
		if(body.hp <= 0):
			queue_free()
		get_node("Sprite").set_hidden(false)
		if ( !is_damaged(body)):
			enemies_hurt.append(body)
		body.take_damage(damage,type)
		if(type == "punch"):
			var r = rand_range(0,2)
			if(r == 0):
				sample_player.play("punch1")
			else:
				sample_player.play("punch2")
		else:
			sample_player.play("punch3")
	elif active and body.is_in_group("barrels"):
		var direction = 1
		if is_player_one:
			direction = game.player.scale.x
		else:
			direction = game.player2.scale.x
		body.take_damage(direction)
	elif active and body.is_in_group("cannons"):
		body.take_damage()
			
			
func _on_timer_timeout():
	self.queue_free()
	
func _on_anim_finished():
	if(type == "super_punch" or type == "super_kick"):
		anim.play("blue")
		particles.set_emitting(true)
	elif(type != "special"):
		anim.play("yellow")

func _ready():
	connect("body_enter", self, "_on_body_enter")
	anim.connect("finished", self, "_on_anim_finished")
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	extended_behavior()
