extends KinematicBody2D


onready var camera = get_node("Camera2D")
onready var area = get_node("Area2D")
onready var back_area = get_node("back_area")
onready var right_wall_collider = get_node("right_wall").get_node("CollisionShape2D")
const MOTION_SPEED = 80
var can_move = false
var playing_animation = false
var hero_present = false
var not_blocked = true

func _on_body_enter(body):
	if(body.is_in_group("heroes")):
		hero_present = true
		
func _on_body_exit(body):
	if(body.is_in_group("heroes")):
		hero_present = false
		
func _on_back_area_body_enter(body):
	if(body.is_in_group("heroes")):
		not_blocked = false

func _on_back_area_body_exit(body):
	if(body.is_in_group("heroes")):
		not_blocked = true

func _process(delta):
	var motion = Vector2(0,0)
	if(can_move and !playing_animation):
		playing_animation = true
		game.HUD.get_node("AnimationPlayer").play("ok_flash")
	elif(!can_move):
		playing_animation = false
	if(can_move and hero_present and  not_blocked):
		motion += Vector2(1,0)
	motion = motion.normalized()*MOTION_SPEED*delta
	motion = move(motion)

func _ready():
	area.connect("body_enter", self, "_on_body_enter")
	area.connect("body_exit", self, "_on_body_exit")
	back_area.connect("body_enter", self, "_on_back_area_body_enter")
	back_area.connect("body_exit", self, "_on_back_area_body_exit")
	set_process(true)
	pass
