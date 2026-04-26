

extends Node

#@onready var sub_viewport_container: SubViewportContainer = $"../SubViewportContainer"

@export_category("Mist Parameters")
@export_range(-2.0, 2.0) var noise_offset_speed_x: float = 0.5
@export_range(-2.0, 2.0) var noise_offset_speed_y: float = 0.1
var add_alpha_shader: float = 0.1
@export_range(-1.0, 0.999) var min_alpha_shader: float = -0.5
@export_range(0.2, 0.999) var max_alpha_shader: float = 0.8
@export_range(0.0, 1.0) var alpha_threshold_shader: float = 0.1
@export_range(0.0, 5.0) var speed_shader: float = 2.0
@export_range(0.0, 20.0) var frequency_shader: float = 10.0
@export_range(0.001, 0.05) var amplitude_shader: float = 10.0
@export_range(0.05, 0.7) var edge_softness_shader: float = 0.4
@export_range(0.01, 0.99) var x_threshold_shader: float = 0.4
@export_range(0.01, 0.99) var dream_level: float = 0.0
@export_range(0.00, 1.00) var dream_darkness: float = 0.0


var reveal_progress_script: float = 0

@export_range(0.00, 1.00) var max_dream_darkness: float = 0.9

@export_range(0.00, 1.00) var max_x_threshold: float = 0.9

@export_category("Assignables")
@export var sub_viewport_container: SubViewportContainer:
	set(value):
		sub_viewport_container = value

@export var dream_darkness_rect: ColorRect:
	set(value):
		dream_darkness_rect = value




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
	GameManager.set_dreamcontroller(self)
	GameManager.connect("cloud_covers_whole_screen", test_print_on_cloud_full)
	GameManager.connect("cloud_is_gone", test_print_cloud_gone)

func _process(delta):
	offset_noise()
	#handle_percentage(delta)
	handle_viewport_size()
	set_shader_params()
	change_dream_level()
	
	#if Input.is_action_just_pressed("skip"):
		#perform_black_wipe_action()
	


func change_dream_level_variable(new_dream_level: float):
	#dream_level = new_dream_level
	print(new_dream_level)
	dream_level = new_dream_level
	#print(new_dream_level)

func change_dream_level():
	x_threshold_shader = dream_level * max_x_threshold
	#add_alpha_shader = -1 + 3 * dream_level
	add_alpha_shader = min_alpha_shader + dream_level * (max_alpha_shader - min_alpha_shader)
	dream_darkness_rect.color.a = dream_level * max_dream_darkness
	
	

func set_shader_params():
	my_material.set_shader_parameter("alpha_addition_threshold", alpha_threshold_shader)
	my_material.set_shader_parameter("max_alpha", max_alpha_shader)
	my_material.set_shader_parameter("add_alpha", add_alpha_shader)
	my_material.set_shader_parameter("speed", speed_shader)
	my_material.set_shader_parameter("frequency", frequency_shader)
	my_material.set_shader_parameter("amplitude", amplitude_shader)
	my_material.set_shader_parameter("edge_softness", edge_softness_shader)
	my_material.set_shader_parameter("x_threshold", x_threshold_shader)
	my_material.set_shader_parameter("character_world_pos", GameManager.dream_character_position)
	my_material.set_shader_parameter("reveal_progress", reveal_progress_script)


func perform_black_wipe_action():
	if not my_material:
		return
	GameManager.cloud_start.emit()
	var tween = create_tween()
	
	# Transition 1: Wipe from left to right (becoming black)
	# Moves reveal_progress from 0.0 to 1.0
	tween.tween_property(self, "reveal_progress_script", 1.0, 2.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_callback(func(): GameManager.cloud_covers_whole_screen.emit())
	
	# Optional: Small delay while everything is black
	tween.tween_interval(0.2)
	
	# Transition 2: Wipe back (restoring texture)
	# Moves reveal_progress from 1.0 back to 0.0
	tween.tween_property(self, "reveal_progress_script", 0.0, 2.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(func(): GameManager.cloud_is_gone.emit())

func test_print_on_cloud_full():
	print("CLOUD COVERS WHOLE SCREEN")
	
func test_print_cloud_gone():
	print("CLOUD GONE")


func offset_noise():
	if noise:
		noise.offset += Vector3(noise_offset_speed_x, noise_offset_speed_y, 0.0)
		
func handle_viewport_size():

	sub_viewport_container.custom_minimum_size.x = 1 + int(container_maximum_x * percentage)
	sub_viewport_container.custom_minimum_size.y = 1 + int(container_maximum_y * percentage)
