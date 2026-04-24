extends Node

@onready var sub_viewport_container: SubViewportContainer = $"../SubViewportContainer"

var my_material: Material = null
var my_perlin_noise: FastNoiseLite = null
var noise: FastNoiseLite = null

func _ready():
	
	my_material = sub_viewport_container.material
	print("a")
	print(my_material)
	var noise_tex = my_material.get_shader_parameter("noise_texture") as NoiseTexture2D
	print("b")

	print(noise_tex)
	
	noise = noise_tex.noise
		

func _process(_delta):
	#print("no")
	offset_noise()

func offset_noise():
	if noise:
		print("yes")
		noise.offset += Vector3(0.5, 0.1, 0.0)
