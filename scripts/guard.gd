extends KinematicBody2D

const STATES = {
	"IDLE": 0,
	"WALK": 1,
	"PUNCH": 2,
	"HURT": 3,
	"FALL": 4,
	"DEATH": 5,
	"HURT_KICK": 6,
	"WINDUP": 7
}

var can_punch = true

# child node declarations
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var action_timer = get_node("action_timer")
onready var punch_position = get_node("punch_position")
onready var punch_timer = get_node("punch_timer")
onready var immunity_timer = get_node("immunity_timer")
onready var feet_collider = get_node("feet_collider")

var camera
var immune = false
var enemy_punch = preload("res://scenes/enemy_punch.tscn")
var shadow = preload("res://scenes/enemy_shadow.tscn")
var explosion = preload("res://scenes/big_explosion.tscn")
var nuke_1 = preload("res://scenes/nuke_1.tscn")
var nuke_2 = preload("res://scenes/nuke_2.tscn")
var fire_ring = preload("res://scenes/big_explosion_2.tscn")
var bone_explosion = preload("res://scenes/bone_explosion.tscn")
var dark_explosion = preload("res://scenes/dark_explosion.tscn")

export var explode = false
export var explosion_type = 0
export var damage = 1
export var hp = 10
export var boss = false
var can_act = true
export var feet_mod = 16
var standing_pos

export var max_distance = 25
export var min_y = 10
var player
var player2
var target
var state
var prev_state

# Member variables
export var MOTION_SPEED = 40# Pixels/seconds
var scale = Vector2(1,1)

func take_damage(damage, type):
	if(!immune):
		hp -= damage
		if(boss):
			game.HUD.update_boss_health_icons(hp)
		if( (hp < 9 and hp%3 == 0 or damage > 2 or(hp > 10 and hp%10 == 0))and hp > 0 ):
			state = STATES.FALL
			game.freeze_time(7)
			action_timer.set_wait_time(3)
			sample_player.play("cry_out")
			immunity_timer.set_wait_time(3)
			shadow.hide()
			#feet_collider.set_trigger(true)
		elif(hp <= 0):
			sample_player.play("cry_out")
			if(boss):
				#game.stream_player.stop()
				game.slow_time(30, 0.03)
				sample_player.play("death")
				game.camera.shake(3,20,6)
			else:
				game.camera.shake(1,10,3)
			state = STATES.DEATH
			if(explode):
				var e
				if(explosion_type == 0):
					e = explosion.instance()
				elif(explosion_type == 1):
					e = nuke_1.instance()
				elif(explosion_type == 2):
					e = fire_ring.instance()
				elif(explosion_type == 3):
					e = nuke_2.instance()
				elif(explosion_type == 4):
				 	e = bone_explosion.instance()
				elif(explosion_type==5):
					e = dark_explosion.instance()
				e.set_global_pos(self.get_global_pos())
				game.current_scene.add_child(e)
				immunity_timer.set_wait_time(1)
				action_timer.set_wait_time(1)
			else:
				immunity_timer.set_wait_time(3)
				action_timer.set_wait_time(3)
			game.freeze_time(7)
			shadow.hide()
			#feet_collider.set_trigger(true)
		else:
			set_global_pos(Vector2(shadow.get_global_pos().x, shadow.get_global_pos().y-feet_mod))
			set_scale(scale)
			if(type == "punch" or type == "special"):
				state = STATES.HURT
			elif(type == "kick" or type == "super_punch" or type=="super_kick"):
				state = STATES.HURT_KICK
				action_timer.set_wait_time(2)
			game.freeze_time(3)
			immunity_timer.set_wait_time(0.1)
		
		var r = rand_range(0,10)
		if r < 3:
			sample_player.play("hurt1")
		elif r < 6:
			sample_player.play("hurt2")
		else:
			sample_player.play("hurt3")
		can_act = false
		immune = true
		immunity_timer.start()
		action_timer.start()
		
func get_new_target():
	if(game.is_2_player):
		var p1_x = abs(player.get_global_pos().x - get_global_pos().x)
		var p1_y = abs(player.get_global_pos().y - get_global_pos().y)
		var p2_x = abs(player2.get_global_pos().x - get_global_pos().x)
		var p2_y = abs(player2.get_global_pos().y - get_global_pos().y)
		if(p1_x < p2_x):
			target = player
		else:
			target = player2
	else:
		target = player
		
func punch():
	state = STATES.PUNCH
	var punch = enemy_punch.instance()
	punch.set_pos(punch_position.get_global_pos())
	punch.set_scale(scale)
	punch.set_damage(damage)
	sample_player.play("attack")
	game.current_scene.add_child(punch)
	can_punch = false
	punch_timer.start()

func player_engaged():
	for e in game.enemy_list:
		if e.state == STATES.PUNCH and e != self and !e.boss:
			return true
	return false
	
#function to decide if its time to punch
func time_to_punch():
	if(abs(target.get_pos().x - self.get_pos().x) < max_distance and 
	   abs(target.get_pos().y - self.get_pos().y) < min_y):
		return true
	else:
		return false

func _fixed_process(delta):
	player = game.player
	if(game.is_2_player):
		player2 = game.player2
	else: 
		player2 = null
	standing_pos = get_global_pos().y + feet_mod
	shadow.set_global_pos(Vector2(get_global_pos().x, standing_pos))
	#print(self.get_name() + "is at position " + str(get_pos().x) + " " + str(get_pos().y))
	#print(self.get_name() + "has a shadow at " + str(shadow.get_pos().x) + " " + str(shadow.get_pos().y))
	get_new_target()
	var motion = Vector2()
	# got to punch state if the player is in range
	if( state != STATES.WINDUP and state != STATES.HURT and state != STATES.DEATH and state != STATES.FALL and (player_engaged() and !game.is_2_player)):
		state = STATES.IDLE
		
	elif( state != STATES.DEATH and 
	    state != STATES.HURT and 
	    state != STATES.FALL and 
	     time_to_punch()):
		if(can_punch):
			state = STATES.WINDUP
	elif( state == STATES.PUNCH):
		state = STATES.IDLE
		action_timer.start()
		can_act = false
	elif( can_act ):
		state = STATES.WALK
		
	#handle knockback state
	var knockback_multiplier = 1
	var knockback_force = Vector2(0,0)
	if(state == STATES.HURT_KICK):
		knockback_multiplier = 2
		knockback_force = Vector2(target.scale.x, 0)
		motion += knockback_force

	# for the walk state, we monitor the player's position and change course to follow
	if(state == STATES.WALK):
		if(rand_range(1,4) == 3):
			state = STATES.IDLE
			can_act = false
			action_timer.start()
		if(can_act):
			if (target.standing_pos - self.standing_pos < -min_y/3 and !shadow.ray_is_colliding("up")):
				var speed = rand_range(0,1)
				motion += Vector2(0, -speed)
			elif (target.standing_pos - self.standing_pos > min_y/3 and !shadow.ray_is_colliding("down")):
				var speed = rand_range(0,1)
				motion += Vector2(0, speed)
			if (target.get_pos().x - self.get_pos().x < -10 and !shadow.ray_is_colliding("left")):
				scale.x = 1
				motion += Vector2(-1, 0)
			elif (target.get_pos().x - self.get_pos().x > 10 and !shadow.ray_is_colliding("right")):
				scale.x = -1
				motion += Vector2(1, 0)
	
	if(state != STATES.FALL and 
	   state != STATES.WINDUP and
	   state != STATES.PUNCH and 
	   state != STATES.HURT and
	   state != STATES.HURT_KICK and
	   state != STATES.DEATH and 
	   motion.x == 0 and motion.y == 0):
		state = STATES.IDLE

	if (state != STATES.IDLE and state != STATES.HURT and state != STATES.FALL and state != STATES.DEATH):
		set_scale(scale)
		
	motion = motion.normalized()*MOTION_SPEED * knockback_multiplier*delta
	motion = move(motion)
	
	# Make character slide nicely through the world
	var slide_attempts = 4
	
	while(is_colliding() and slide_attempts > 0):
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1
		
	var animationName = ""
	if(state == STATES.WALK):
		animationName = "walk"
	elif(state == STATES.IDLE):
		animationName = "idle"
	elif(state == STATES.PUNCH):
		animationName = "punch"
	elif(state == STATES.HURT):
		animationName = "hurt"
	elif(state == STATES.FALL):
		animationName = "fall"
	elif(state == STATES.DEATH):
		animationName = "death"
	elif(state == STATES.HURT_KICK):
		animationName = "hurt_kick"
	elif(state == STATES.WINDUP):
		animationName = "windup"

	if(!anim.is_playing() or
	(state == STATES.WALK and prev_state != STATES.WALK) or
	(state == STATES.PUNCH and prev_state != STATES.PUNCH) or
	(state == STATES.HURT and prev_state != STATES.HURT) or
	(state == STATES.FALL and prev_state != STATES.FALL) or
	(state == STATES.DEATH and prev_state != STATES.DEATH) or
	(state == STATES.IDLE and prev_state != STATES.IDLE) or
	(state == STATES.HURT_KICK and prev_state != STATES.HURT_KICK) or
	(state == STATES.WINDUP and prev_state != STATES.WINDUP)):
		anim.play(animationName)

	prev_state = state
	
# the immunity timer will track how long the enemy is immune to damage
func _on_immunity_timer_timeout():
	if(state == STATES.HURT or state == STATES.HURT_KICK):
		state = STATES.IDLE
	if(state != STATES.DEATH):
		shadow.show()
	#feet_collider.set_trigger(false)
	immunity_timer.stop()
	immune = false
	
func _on_punch_timer_timeout():
	punch_timer.stop()
	can_punch = true
	punch_timer.set_wait_time(2)
	if(state != STATES.FALL and state != STATES.HURT and state != STATES.DEATH):
		if (target.get_pos().x - self.get_pos().x < 0):
			scale.x = 1
		elif (target.get_pos().x - self.get_pos().x  > 0):
			scale.x = -1
	
func _on_action_timer_timeout():
	if( hp <= 0):
		game.remove_from_enemy_list(self)
		self.set_process(false)
		self.queue_free()
	action_timer.set_wait_time(rand_range(1,3))
	can_act = true
	action_timer.stop()
	
func _on_animation_finished():
	if(state == STATES.WINDUP):
		punch()

func _ready():
	if(!boss):
		MOTION_SPEED += rand_range(-20,20)
	standing_pos = get_pos().y + feet_mod
	shadow = shadow.instance()
	shadow.is_enemy = true
	shadow.set_pos(Vector2(get_pos().x, standing_pos))
	self.add_child(shadow)
	shadow.set_z(get_z()-1)
	# add this guard to the main list of enemies in the global game class
	game.add_to_enemy_list(self)
	#print(self.get_name() + "is at position " + str(get_pos().x) + " " + str(get_pos().y))
	#print(self.get_name() + "has a shadow at " + str(shadow.get_pos().x) + " " + str(shadow.get_pos().y))
	#set the beginning state
	state = STATES.WALK
	prev_state = STATES.IDLE
	#grab the player node from the scene
	player = game.player
	if(game.is_2_player):
		player2 = game.player2
	else: 
		player2 = null
		
	if(boss):
		game.HUD.initialize_boss(hp)
	#connect the timer signals to their necessary methods
	action_timer.connect("timeout", self, "_on_action_timer_timeout")
	punch_timer.connect("timeout", self, "_on_punch_timer_timeout")
	immunity_timer.connect("timeout", self, "_on_immunity_timer_timeout")
	anim.connect("finished", self, "_on_animation_finished")
	camera = game.camera
	set_fixed_process(true)