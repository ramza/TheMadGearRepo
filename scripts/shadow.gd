extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var ray_up = get_node("raycast_up")
onready var ray_down = get_node("raycast_down")
onready var ray_right = get_node("raycast_right")
onready var ray_left = get_node("raycast_left")

var is_enemy = false

func ray_is_colliding(var dir):
	if(dir == "up" and ray_up.is_colliding()):
		return true
	elif(dir == "down" and ray_down.is_colliding()):
		return true
	elif(dir == "left" and ray_left.is_colliding()):
		#if this instance is of an enemy shadow and not a hero shadow
		if(is_enemy):
			#get the collider and return false if its an ignore wall
			var col = ray_left.get_collider()
			if(col == null || col.is_in_group("ignore")):
				return false
			else: 
				return true
		else:
			return true
	elif(dir == "right" and ray_right.is_colliding()):
			#if this instance is of an enemy shadoe and not a hero shadow
		if(is_enemy):
			#get the collider and return false if its an ignore wall
			var col = ray_right.get_collider()
			if(col == null || col.is_in_group("ignore")):
				return false
			else: 
				return true
		else:
			return true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
