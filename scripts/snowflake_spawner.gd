#@tool

extends Node2D


@export var snowflakes_per_interval: int = 10
@export var interval_length: float = 0.5
@export var limit_1: Node2D
@export var limit_2: Node2D

@export var min_x_speed: float = 10
@export var max_x_speed: float = 10
@export var y_multiplier_speed: float = 10

@export var snowflake_storage: Node2D


var last_spawn: float = 0

const SNOWFLAKE = preload("uid://dk0lweb4hacd5")

func _process(delta):
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_spawn >= interval_length:
		spawn_snowflakes()
		last_spawn = current_time
		

func spawn_snowflakes():
	for i in range(snowflakes_per_interval):
		spawn_random_snowflake()


func spawn_random_snowflake():
	var snowflake_instance = SNOWFLAKE.instantiate()
	snowflake_storage.add_child(snowflake_instance)
	snowflake_instance.position = select_random_position()
	snowflake_instance.rotation = randi_range(0, 360)
	snowflake_instance.x_speed = randf_range(min_x_speed, max_x_speed)
	snowflake_instance.y_multiplier_speed = y_multiplier_speed
	

func select_random_position() -> Vector2:
	var x: int = randi_range(limit_1.global_position.x, limit_2.global_position.x)
	var y: int = randi_range(limit_1.global_position.y, limit_2.global_position.y)
	return Vector2(x, y)
