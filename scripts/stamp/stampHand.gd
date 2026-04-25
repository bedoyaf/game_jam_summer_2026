extends Node2D

@export_group("Visuals")
@export var idle_sprite: Sprite2D   
@export var stamp_sprite: Sprite2D  

@export_group("Settings")
@export var follow_speed: float = 15.0   
@export var click_scale: float = 0.85    
@export var click_duration: float = 0.35 

@export var cooldown_time: float = 0.35  

var target_pos: Vector2
var click_timer := 0.0
var cooldown_timer := 0.0 

func _ready():
	target_pos = global_position

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	if idle_sprite: idle_sprite.show()
	if stamp_sprite: stamp_sprite.hide()

func _process(delta: float) -> void:

	target_pos = get_global_mouse_position()
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if click_timer > 0.0:
		click_timer -= delta
		if click_timer <= 0.0:

			scale = Vector2.ONE
			if idle_sprite: idle_sprite.show()
			if stamp_sprite: stamp_sprite.hide()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		if GameManager.is_stamp_allowed():
			GameManager.record_stamp() 

			_do_click()

func _do_click():

	click_timer = click_duration
	cooldown_timer = cooldown_time

	scale = Vector2(click_scale, click_scale)
	if idle_sprite: idle_sprite.hide()
	if stamp_sprite: stamp_sprite.show()

	_check_interaction()

func _check_interaction():
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_point(query)

	for item in results:
		var collider = item.collider

		var node = collider
		while node:
			if node.has_method("on_stamp"):
				node.on_stamp()
				break
			node = node.get_parent()
