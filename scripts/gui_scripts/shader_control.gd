extends Node
@export var shader_alpha: float = 0.5
@export var my_speed: float = 10

@onready var color_rect: ColorRect = $ColorRect
@onready var sprite_2d: Sprite2D = $Sprite2D


func _process(delta):
	#print(shader_alpha)
	#set_shader_alpha(shader_alpha)
	move_stuff(delta)
		
func set_shader_alpha(my_shader_alpha: float):
	color_rect.material.set_shader_parameter("my_alpha", my_shader_alpha)

func move_stuff(delta):
	if Input.is_action_pressed("ui_right"):
		sprite_2d.position.x += my_speed
	if Input.is_action_pressed("ui_left"):
		sprite_2d.position.x += my_speed
