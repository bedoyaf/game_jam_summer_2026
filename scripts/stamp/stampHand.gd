extends Node2D

@export var follow_speed: float = 15.0   # jak rychle dohání myš (vyšší = méně smooth)
@export var click_scale: float = 0.85    # "zmáčknutí" při kliknutí
@export var click_duration: float = 0.08

var target_pos: Vector2
var is_clicking := false
var click_timer := 0.0

func _ready():
	target_pos = global_position

func _process(delta: float) -> void:
	# pozice myši
	target_pos = get_global_mouse_position()
	
	# SMOOTH pohyb (lerp)
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))
	
	# klik animace
	if is_clicking:
		click_timer -= delta
		if click_timer <= 0.0:
			scale = Vector2.ONE
			is_clicking = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		_do_click()

func _do_click():
	# malá squash animace (razítko efekt)
	scale = Vector2(click_scale, click_scale)
	is_clicking = true
	click_timer = click_duration
	
	# tady řešíš interakci
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
		
		# zkus najít script výš ve stromu
		var node = collider
		while node:
			if node.has_method("on_stamp"):
				node.on_stamp()
				break
			node = node.get_parent()
