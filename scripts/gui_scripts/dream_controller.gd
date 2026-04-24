extends Node

@onready var sub_viewport_container: SubViewportContainer = $"../SubViewportContainer"

var my_material: Material = null
var my_perlin_noise: FastNoiseLite = null
var noise: FastNoiseLite = null
var percentage: float = 0
var percentage_speed: float = 0.2

var container_minimum_x: int = 1
var container_minimum_y: int = 1

var container_maximum_x: int = 1200
var container_maximum_y: int = 800

func _ready():
	
	my_material = sub_viewport_container.material
	var noise_tex = my_material.get_shader_parameter("noise_texture") as NoiseTexture2D

	
	noise = noise_tex.noise
		

func _process(delta):
	#print("no")
	offset_noise()
	handle_percentage(delta)
	handle_viewport_size()
	
func handle_percentage(delta):
	if Input.is_action_pressed("ui_right"):
		percentage += delta * percentage_speed
		if percentage > 1:
			percentage = 1
	if Input.is_action_pressed("ui_left"):
		percentage -= delta * percentage_speed
		if percentage < 0:
			percentage = 0
	

func offset_noise():
	if noise:
		noise.offset += Vector3(0.5, 0.1, 0.0)
		
func handle_viewport_size():
	sub_viewport_container.custom_minimum_size.x = 1 + int(container_maximum_x * percentage)
	sub_viewport_container.custom_minimum_size.y = 1 + int(container_maximum_y * percentage)
