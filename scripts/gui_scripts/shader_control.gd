extends Node
@export var shader_alpha: float = 0.5

@onready var color_rect: ColorRect = $ColorRect


func _process(delta):
	print(shader_alpha)
	set_shader_alpha(shader_alpha)
		
func set_shader_alpha(my_shader_alpha: float):
	color_rect.material.set_shader_parameter("my_alpha", my_shader_alpha)
