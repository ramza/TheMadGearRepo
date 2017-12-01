extends Node2D

const STATES = {

	"DOWN": 0,
	"RISE": 1,
	"UP": 2,
	"DROP": 3
}

var state
var start_pos = Vector2(0,0)
var active = false

onready var wall = get_node("Wall")
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var static_body = get_node("Wall").get_node("StaticBody2D")
onready var sample_player = get_node("SamplePlayer2D")
onready var area = get_node("Wall").get_node("Area2D")
onready var shadow = get_node("Shadow")
onready var shadow_area = get_node("Shadow").get_node("Area2D")
onready var killzone = get_node("killzone")
onready var activation_zone = get_node("activation_zone")

func _process(delta):
	var bodies = shadow_area.get_overlapping_bodies()
	if(active and state == STATES.DROP):
		for body in bodies:
			if(body.is_in_group("heroes")):
				if(shadow_area.overlaps_area(game.current_scene.get_node("shadow").get_node("Area2D"))):
					body.take_damage("wall", 3)
			elif(body.is_in_group("enemies")):
				body.take_damage(3, "wall")

func _on_wall_anim_finished():
	if active:
		if(state == STATES.DOWN):
			state = STATES.RISE
		if(state == STATES.RISE):
			state = STATES.UP
		elif(state == STATES.UP):
			state = STATES.DROP
			sample_player.play('wall')
		elif(state == STATES.DROP):
			state = STATES.DOWN
		var anim_name = "down"
		if(state == STATES.DOWN):
			anim_name = "down"
		elif(state == STATES.RISE):
			anim_name = "rise"
		elif(state == STATES.DROP):
			anim_name = "drop"
		elif(state == STATES.UP):
			anim_name = "up"
		if(!anim.is_playing()):
			anim.play(anim_name)

func _on_wall_timer_timeout():
	pass

func _on_shadow_body_enter(body):
	pass
		
			
func _on_wall_body_enter(body):
	if(body.is_in_group("heroes") or body.is_in_group("enemies")):
		body.set_z(0)
			
func _on_killzone_body_enter(body):
	if body.is_in_group("heroes"):
		queue_free()
		
func _on_activation_zone_body_enter(body):
	if !active and body.is_in_group("heroes"):
		active = true
		anim.play("down")

func _ready():
	state = STATES.DOWN
	start_pos = shadow.get_global_pos()
	#shadow_area.connect("body_enter", self, "_on_shadow_body_enter")
	#area.connect("body_enter", self, "_on_wall_body_enter")
	anim.connect("finished", self, "_on_wall_anim_finished")
	killzone.connect("body_enter", self, "_on_killzone_body_enter")
	activation_zone.connect("body_enter", self, "_on_activation_zone_body_enter")
	timer.connect("timeout", self, "_on_wall_timer_timeout")
	timer.start()
	set_process(true)