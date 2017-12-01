#jumping branch
extends KinematicBody2D

const STATES = {
	"IDLE": 0,
	"WALK": 1,
	"JUMP": 2,
	"PUNCH": 3,
	"KICK": 4,
	"HURT": 5,
	"FALL": 6,
	"SPECIAL": 7,
	"JUMP_KICK": 8,
	"THROW": 9,
	"DEATH": 10,
	"ROCK": 11
}
# Member variables
const MOTION_SPEED = 100# Pixels/seconds
const JUMP_FORCE = 160
const GRAVITY = 200
const MAX_JUMP_TIME = 14
const MAX_COMBO_TIME = 80

var scale = Vector2(1,1)
var state = STATES.IDLE
var prevState = state
var can_attack = true;
var attack_flag = false;
var can_jump = true
var can_kick = true
var punch_counter = 0
var punch_ticker = 0
var score = 0
var feet_mod = 16
var standing_pos

var jump_cost = 10

var hp = 10
var max_hp = 10
var mp = 100
var max_mp = 150
var damage = 1
var immune = false
var jumping = false
var punching = false
var is_combo = false
var has_bat = false
var bat_hit_counter = 0
var max_bat_hits = 20
var shadow_pos
var feet_pos
var death_penatly = 200
var kick_cost = 20
var punch_cost = 10
var special_cost = 65
var stamina_regen_timer = 0
var stamina_regen_delay = 5
var passive_counter = 0
var passive_timer = 0
var passive_delay = 2
var passive_switch = false

var jumpTimer = 0
export var player_1 = true
var was_player_2 = false
var jump_start_pos

# node references
var camera
var shadow
onready var anim = get_node("AnimationPlayer")
onready var attack_timer = get_node("attack_timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var punch_position = get_node("punch_position")
onready var kick_position = get_node("kick_position")
onready var combo_timer = get_node("combo_timer")
onready var feet_collider = get_node("feet_collider")
onready var immunity_timer = get_node("immunity_timer")
onready var super_saiyan_timer = get_node("super_saiyan_timer")
onready var particles = get_node("Particles2D")
onready var music_particles = get_node("music_particles")
onready var electric_particles = get_node("electric_particles")

var shadow_scene = preload("res://scenes/shadow.tscn")
var hero_punch = preload("res://scenes/hero_punch.tscn")
var shreddy_axe = preload("res://scenes/shreddy_axe.tscn")
var jump_trail = preload("res://scenes/jump_trail.tscn")
var dust = preload("res://scenes/dust.tscn")
var text_popup = preload("res://scenes/text_popup.tscn")

var is_super_saiyan = false
		
func set_single_player(value):
	player_1 = value
	
func special_attack(motion):
	return motion
	
func _fixed_process(delta):

	if(mp > max_mp-10):
		electric_particles.set_emitting(true)
	else:
		electric_particles.set_emitting(false)
	if (is_super_saiyan):
		mp = max_mp
		if(game.is_2_player and !player_1):
			game.HUD.update_player2_special_bar(float(mp)/max_mp)
		else:
			game.HUD.update_special_bar(float(mp)/max_mp)
		if(!sample_player.is_voice_active(1)):
			sample_player.play("super_saiyan",1)
	stamina_regen_timer += 1
	if(stamina_regen_timer > stamina_regen_delay):
		stamina_regen_timer = 0
		mp += 1
		if(mp >= max_mp):
			mp = max_mp
		if(player_1):
			game.HUD.update_special_bar(float(mp)/max_mp)
		else:
			game.HUD.update_player2_special_bar(float(mp)/max_mp)
	if(shadow == null):
		shadow = shadow_scene.instance()
		shadow.set_z(1)
		game.current_scene.add_child(shadow)
	else:
		standing_pos = shadow.get_global_pos().y
	if(!jumping):
		shadow.set_z(get_z()-1)
		self.set_z(self.get_z())
		shadow_pos = get_global_pos()
		shadow_pos.y += 16
		shadow.set_global_pos(shadow_pos) 
		feet_pos = get_global_pos()
		feet_pos.y += 16
		feet_collider.set_global_pos(feet_pos)
		#feet_collider.set_trigger(false)
	if(punching):
		punch_ticker+=1
		#print(punch_ticker)
		#print(punch_counter)
		if(punch_counter >= 3):
			is_combo = true
		if(punch_ticker > MAX_COMBO_TIME):
			punch_ticker = 0
			punch_counter = 0
			is_combo = false
			punching = false
		
	var motion = Vector2(0,0)
	
	var kick = false
	var punch = false
	var passive = false
	var move_up = false
	var move_down = false
	var move_left = false
	var move_right = false
	var jump = false
	
	if(player_1 and !was_player_2 and !game.was_2_player):
		kick = Input.is_action_pressed("kick")
		punch = Input.is_action_pressed("punch")
		passive = Input.is_action_pressed("passive")
		move_up = Input.is_action_pressed("move_up")
		move_down = Input.is_action_pressed("move_down")
		move_left = Input.is_action_pressed("move_left")
		move_right = Input.is_action_pressed("move_right")
		jump = Input.is_action_pressed("jump")
	else:
		kick = Input.is_action_pressed("p2_kick")
		punch = Input.is_action_pressed("p2_punch")
		passive = Input.is_action_pressed("p2_passive")
		move_up = Input.is_action_pressed("p2_move_up")
		move_down = Input.is_action_pressed("p2_move_down")
		move_left = Input.is_action_pressed("p2_move_left")
		move_right = Input.is_action_pressed("p2_move_right")
		jump = Input.is_action_pressed("p2_jump")
	
	if(has_bat):
		kick = false
		jump = false
	
	if(can_attack and !passive):
		if (move_up and !is_colliding() and !shadow.ray_is_colliding("up") and !jumping):
			motion += Vector2(0, -1)
			#shadow_pos.y -= 1
		if (move_down and !is_colliding() and !shadow.ray_is_colliding("down") and !jumping):
			motion += Vector2(0, 1)
			#shadow_pos.y += 1
		if (move_left and !is_colliding() and !shadow.ray_is_colliding("left")):
			motion += Vector2(-1, 0)
			if(scale.x != -1):
				scale.x = -1
		if (move_right and !is_colliding() and !shadow.ray_is_colliding("right")):
			motion += Vector2(1, 0)
			if(scale.x != 1):
				scale.x = 1
	# set flag for second attack type. set a flag if the player pushed
	# punch before the attack timer runs out
	if(!can_attack and punch):
		attack_flag = !attack_flag
	if(!passive):
		music_particles.set_emitting(false)
	if(passive and can_attack):
		state = STATES.ROCK
		music_particles.set_emitting(true)
		#game.camera.shake(0.3,1,1)
		if(!sample_player.is_voice_active(0)):
			var r = rand_range(0,100)
			if(r < 25):
				sample_player.play("rock_out",0)
			elif(r < 50):
				sample_player.play("rock_out_2",0)
			elif(r < 75):
				sample_player.play("rock_out_3",0)
			else:
				sample_player.play("rock_out_4",0)
		passive_timer+=1
		if(passive_timer>passive_delay):
			passive_timer = 0 
			mp+=1
	elif(jump and can_attack and mp > jump_cost):
		if(!jumping):
			var trail = jump_trail.instance()
			trail.set_global_pos(get_global_pos())
			jump_start_pos = get_global_pos()
			game.current_scene.add_child(trail)
			jumping = true
			mp -= jump_cost 
			punch_counter = 0
	#case for special attack
	elif(punch and kick and can_attack and mp >= special_cost and !jumping):
		motion = special_attack(motion)
	#conditions for throwing attack
#	elif(prevState != STATES.THROW and (move_left or move_right) and punch and can_attack):
#		state = STATES.THROW
#		print("throw")
#		motion = Vector2(0,0)
#		can_attack = false
#		attack_timer.set_wait_time(0.5)
#		attack_timer.start()
	# handle the punch state by creating a hero_punch object
	# that will damange enemies
	elif(punch and can_attack and !jumping and mp >= punch_cost):
		motion = Vector2(0,0)
		state = STATES.PUNCH
		sample_player.play("swing", 0)
		can_attack = false
		punching = true
		var type = "punch"
		if(mp == max_mp):
			type = "super_punch"
			mp-=30
		else:
			mp -= punch_cost
		if(punch_counter > 3):
			attack_timer.set_wait_time(0.5)
		else:
			attack_timer.set_wait_time(0.3)
		attack_timer.start()
		var punch = hero_punch.instance()
		if(has_bat):
			type = "bat"
			attack_timer.set_wait_time(0.5)
		punch.set_type(type)
		if(!player_1):
			punch.set_player_one(false)
		punch.set_pos(punch_position.get_global_pos())
		punch.set_scale(scale)
		game.current_scene.add_child(punch)
	
	#this bit handles both the ground kick and the jump kick
	elif(kick and can_attack and can_kick and mp >= kick_cost):
		sample_player.play("swing",0)
		if(jumping):
			state = STATES.JUMP_KICK
			can_kick = false
			#can_attack = false
			attack_timer.set_wait_time(0.4)
		else:
			can_attack = false
			motion = Vector2(0,0)
			state = STATES.KICK
			if(punch_counter > 3):
				attack_timer.set_wait_time(1)
			else:
				attack_timer.set_wait_time(0.4)
			punching = true
		
		attack_timer.start()
		var punch = hero_punch.instance()
		punch.set_type("kick")
		if(mp == max_mp):
			punch.set_type("super_kick")
			mp-=30
		else:
			mp -= kick_cost
		if(!player_1):
			punch.set_player_one(false)
		punch.set_pos(kick_position.get_global_pos())
		punch.set_scale(scale)
		game.current_scene.add_child(punch)
	#set the player to an idle state if not moving or attacking
	elif(motion.x == 0 and motion.y == 0 and state != STATES.DEATH and state != STATES.JUMP_KICK and state != STATES.HURT and state != STATES.FALL and state != STATES.THROW):
		state = STATES.IDLE
	#not implemented yet, every other case
	elif(state == STATES.HURT or state == STATES.FALL or state == STATES.JUMP_KICK):
		pass
	#if nothing else, we're walking
	elif(state != STATES.THROW and state != STATES.DEATH):
		state = STATES.WALK
			
	set_scale(scale)
	#to jump we have to find our distance fromt the ground based on the shadow object
	#we register its place on the floor when we jump and then track it
	if(jumping):
		jumpTimer+=1
		#feet_collider.set_trigger(true)
		motion = motion*MOTION_SPEED*delta
		if(jumpTimer == MAX_JUMP_TIME/2):
			sample_player.play("jump", 0)
		if(jumpTimer > MAX_JUMP_TIME):
			var force = Vector2(0, GRAVITY)*delta
			motion += force
			
			if(get_global_pos().y+18 >= shadow_pos.y):
				state = STATES.IDLE
				sample_player.play("swing", 0)
				var d = dust.instance()
				d.set_global_pos(get_global_pos())
				game.current_scene.add_child(d)
				jumping = false
				jumpTimer = 0
				motion = Vector2(0,0);
				set_global_pos(Vector2(shadow_pos.x, shadow_pos.y-16))
				
				can_attack = false
				attack_timer.set_wait_time(0.01)
				attack_timer.start()
		else:
			motion += Vector2(0, -JUMP_FORCE) * delta

		if(state != STATES.JUMP_KICK):
			state = STATES.JUMP
		shadow_pos.x = get_global_pos().x
		shadow.set_global_pos(shadow_pos)
		feet_pos.x = shadow_pos.x
		
		#feet_collider.set_global_pos(feet_pos)
	else:
		motion = motion.normalized()*MOTION_SPEED*delta
		
	motion = move(motion)
	
	# Make character slide nicely through the world
	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0 and !jumping):
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1
		
	# handle animation states
	var animationName = ""
	if(state == STATES.IDLE):
		if(has_bat):
			animationName = "bat_idle"
		elif(mp< max_mp*.1):
			animationName = "tired"
		else:
			animationName = "idle"
	elif(state == STATES.PUNCH):
		if(has_bat):
			animationName = "bat_attack"
			punch_counter = 0
			is_combo = false
		elif(is_combo):
			animationName = "uppercut"
			punch_counter = 0
			is_combo = false
			
		elif(attack_flag):
			animationName = "punch2"
			attack_flag = false
		elif(!attack_flag):
			animationName = "punch1"
	elif(state == STATES.KICK):
		if(is_combo):
			animationName = "roundhouse"
			punch_counter = 0
			is_combo = false
		else:
			animationName = "kick1"
	elif(state == STATES.WALK):
		if(has_bat):
			animationName = "bat_walk"
		else:
			animationName = "walk"
	elif(state == STATES.HURT):
		if(has_bat):
			animationName = "bat_hurt"
		else:
			animationName = "hurt"
	elif(state == STATES.FALL):
		animationName = "fall"
	elif(state == STATES.SPECIAL):
		animationName = "special"
	elif(state == STATES.JUMP):
		animationName = "jump"
	elif(state == STATES.JUMP_KICK):
		animationName = "jump_kick"
	elif(state == STATES.THROW):
		animationName = "throw"
	elif(state == STATES.DEATH):
		animationName = "death"
	elif(state == STATES.ROCK):
		animationName = "rock_out"
	
	if(!anim.is_playing() or 
		(state == STATES.WALK and prevState != STATES.WALK) or
		(state == STATES.IDLE and prevState == STATES.WALK) or
		(state == STATES.IDLE and prevState == STATES.DEATH) or
		(state == STATES.PUNCH) or
		(state == STATES.KICK) or
		(state == STATES.HURT and prevState != STATES.HURT) or
		(state == STATES.FALL and prevState != STATES.FALL) or
		(state == STATES.DEATH and prevState != STATES.DEATH) or
		(state == STATES.SPECIAL and prevState != STATES.SPECIAL) or
		(state == STATES.JUMP and prevState != STATES.JUMP) or
		(state == STATES.IDLE and prevState == STATES.JUMP) or
		(state == STATES.JUMP_KICK) or
		(state == STATES.THROW) or
		(state == STATES.ROCK and prevState != STATES.ROCK)):
		anim.play(animationName)
		
	prevState = state
	
func _on_super_saiyan_timer_timeout():
	is_super_saiyan = false
	particles.set_emitting(false)
	
func _on_immunity_timer_timeout():
	immunity_timer.stop()
	if(state == STATES.DEATH):
		immune = true
		score -= death_penatly
		if(game.is_2_player and !player_1):
			game.player2_score = score
			game.HUD.update_player2_score(score)
		else:
			game.player1_score = score
			game.HUD.update_player1_score(score)
		if(score <= 0 && !game.is_2_player):
			game.game_over = true
			game.HUD.play_fade("fade_out")
			game.HUD.reset_timer.start()
		elif(score <= 0 && game.is_2_player):
			if(player_1):
				game.player = game.player2
				game.HUD.update_player1_score(game.player.score)
				game.HUD.update_player_one_health(game.player.hp)
				game.player.player_1 = true
				game.player.was_player_2 = true
				game.was_2_player = true
				game.prev_player_1_index = game.player_index
				game.player_index = game.player2_index
				game.player2 = null
			game.is_2_player=false
			game.character_list.remove(game.character_list.find(self))
			game.HUD.get_node("p2_center").hide()
			game.HUD.update_player_two_health(0)
			self.queue_free()
		else:
			respawn()
	else:
		immune = false
		get_node("Sprite").set_modulate(Color(1,1,1))
		
func respawn():
	hp = max_hp
	if(game.is_2_player and !player_1):
		game.HUD.update_player_two_health(hp)
	else:
		game.HUD.update_player_one_health(hp)
	state = STATES.IDLE
	immune = true
	can_attack = true
	immunity_timer.set_wait_time(2)
	immunity_timer.start()
	print("player respawn")

func _on_attack_timer_timeout():
	attack_timer.stop()
	
	attack_timer.set_wait_time(0.3)
	if(state == STATES.THROW or state == STATES.HURT or state == STATES.FALL or state == STATES.SPECIAL):
		state = STATES.IDLE
		shadow.set_hidden(false)
	
	if(bat_hit_counter >= max_bat_hits):
		has_bat = false
		bat_hit_counter = 0
	can_attack = true
	can_kick = true

func disable():
	set_fixed_process(false)
	
func drink_bottle(energy_bonus):
	is_super_saiyan = true
	particles.set_emitting(true)
	super_saiyan_timer.start()

func eat_food(type, health_bonus):
	if (type == "burger"):
		pass
	hp += health_bonus
	if ( hp > max_hp):
		hp = max_hp
	mp = max_mp
	if(game.is_2_player and !player_1):
		game.HUD.update_player_two_health(hp)
	else:
		game.HUD.update_player_one_health(hp)

func get_score():
	return score

func set_score(value):
	score = value
	
func throw():
	pass
	
func new_text_popup(var text):
	var t = text_popup.instance()
	t.set_global_pos(Vector2(rand_range(get_global_pos().x-10,get_global_pos().x+10), get_global_pos().y-32))
	t.get_node("Label").set_text(text)
	game.current_scene.add_child(t)
		
func take_damage(type, damage):
	if(!immune):
		immune = true
		hp -= damage
		var sample = "hurt"
		if(game.is_2_player and !player_1):
			game.HUD.update_player_two_health(hp)
		else:
			game.HUD.update_player_one_health(hp)
		if(hp <= 0):
			if(is_super_saiyan):
				is_super_saiyan = false
				_on_super_saiyan_timer_timeout()
			jumping = false
			state = STATES.DEATH
			new_text_popup("-"+str(death_penatly))
			game.freeze_time(10)
			camera.shake(1,15,5)
			attack_timer.set_wait_time(7)
			immunity_timer.set_wait_time(2)
			shadow.set_hidden(true)
			sample = "death"
			game.slow_time(30,0.05)
		elif(!is_super_saiyan and (hp%3 == 0 or jumping or damage > 2)):
			jumping = false
			set_global_pos(Vector2(shadow_pos.x, shadow_pos.y-16))
			camera.shake(1,10,3)
			state = STATES.FALL
			attack_timer.set_wait_time(2)
			immunity_timer.set_wait_time(2)
			shadow.set_hidden(true)
			sample = "hurt2"
		else:
			state = STATES.HURT
			get_node("Sprite").set_modulate(Color(10,0,0))
			attack_timer.set_wait_time(0.5)
			immunity_timer.set_wait_time(0.5)

		sample_player.play(sample, 0)
		can_attack = false
		attack_timer.start()
		immunity_timer.start()
		
func update_score(var bonus):
	score += bonus
	if bonus >= 100:
		new_text_popup("+"+str(bonus))
	if(player_1):
		game.HUD.update_player1_score(score)
	else:
		game.HUD.update_player2_score(score)

func _ready():
	standing_pos = get_pos().y + feet_mod
	particles.set_emitting(false)
	music_particles.set_emitting(false)
	electric_particles.set_emitting(false)
	jump_start_pos = get_global_pos()
	super_saiyan_timer.connect("timeout", self, "_on_super_saiyan_timer_timeout")
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	immunity_timer.connect("timeout", self, "_on_immunity_timer_timeout")
	camera = game.current_scene.get_node("camera_rig").get_node("Camera2D")
	set_fixed_process(true)