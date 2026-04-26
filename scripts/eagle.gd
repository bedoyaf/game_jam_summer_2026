extends Node2D

@export var orbit_radius: float = 100.0
@export var orbit_speed: float = 0.8
@export var dodge_distance: float = 50.0 # How close the mouse can get before a dodge
@export var max_dodges: int = 3
@export var sprite_rotation_offset_deg: float = 90.0 # Change to 0 if your sprite naturally points right

var orbit_center: Vector2 = Vector2.ZERO
var current_angle: float = 0.0
var dodges_left: int
var dodge_timer: float = 0.0
var base_scale: Vector2 = Vector2.ONE

@onready var sprite = $Sprite2D
@onready var stamp_goal = $StampGoal

@onready var eagle_cry: AudioStreamPlayer = $EagleCry
@onready var eagle_swoosh_1: AudioStreamPlayer = $EagleSwoosh1
@onready var eagle_swoosh_2: AudioStreamPlayer = $EagleSwoosh2

var last_eagle_cry_sound: float = 0
var eagle_cry_interval: float = 5

var last_eagle_swoosh_sound: float = 0
var eagle_swoosh_interval: float = 3.5
var has_already_appeared: bool = false

func _ready() -> void:
	dodges_left = max_dodges
	base_scale = scale
	
	# Use the initial placement in your scene as the center of the orbit!
	orbit_center = global_position 
	
	# The eagle only takes exactly 1 hit to die, but it dodges the hand 3 times first!
	if stamp_goal:
		stamp_goal.required_hits = 1
		stamp_goal.completed.connect(_on_eagle_defeated)

func _process(delta: float) -> void:
	# If exhausted, circle slowly, waiting for the player to stamp it!
	if dodges_left <= 0:
		_update_orbit(delta * 0.4) 
		return
		
	# sound
	try_play_swoosh()

	# If currently dodging, wait before checking distance again
	if dodge_timer > 0.0:
		dodge_timer -= delta
	else:
		_update_orbit(delta)
		_check_dodge()

func _update_orbit(delta: float) -> void:
	current_angle += orbit_speed * delta
	
	# Basic Trigonometry to calculate position on a circle
	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	var target_pos = orbit_center + offset
	
	# Calculate exact mathematical tangent of the circle so it rotates natively every frame
	var tangent_angle = current_angle + (PI / 2.0 if orbit_speed > 0 else -PI / 2.0)
	
	# Smoothly interpolate rotation so it looks organic when recovering from a dodge
	var target_rotation = tangent_angle + deg_to_rad(sprite_rotation_offset_deg)
	rotation = lerp_angle(rotation, target_rotation, 8.0 * delta)
		
	global_position = target_pos

func _check_dodge() -> void:
	# Only dodge if the eagle task is actually the CURRENT active task!
	if stamp_goal and not stamp_goal.is_active:
		return
		
	# `get_global_mouse_position()` inside the Eagle script pulls the correctly projected
	# coordinate of the mouse in the Dream World! (Completely avoids Subviewport issues!)
	var mouse_pos = get_global_mouse_position()
	
	if global_position.distance_to(mouse_pos) < dodge_distance:
		_trigger_dodge()

func _trigger_dodge() -> void:
	dodges_left -= 1
	dodge_timer = 0.45 # Quick cooldown so it doesn't double-dodge
	
	# Add PI (180 degrees) to instantly jump to the opposite side of its orbit!
	current_angle += PI 
	
	var new_offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	var new_pos = orbit_center + new_offset
	
	# Snap rotation to face the darting direction!
	var dash_dir = new_pos - global_position
	if dash_dir.length_squared() > 1.0:
		rotation = dash_dir.angle() + deg_to_rad(sprite_rotation_offset_deg)
	
	# "Juice": Smooth, fast flight to the new position
	var tween = create_tween()
	tween.tween_property(self, "global_position", new_pos, 0.45).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# "Juice": Stretch the eagle dynamically based on its original size!
	scale = Vector2(base_scale.x * 1.5, base_scale.y * 0.5)
	tween.parallel().tween_property(self, "scale", base_scale, 0.45).set_trans(Tween.TRANS_BOUNCE)
	
	if dodges_left <= 0:
		print("Eagle Exhausted! Ready for Stamping!")
		# Make it turn slightly gray/sad so the player knows it gave up
		modulate = Color(0.7, 0.7, 0.9) 


func _on_appears_on_screen():
	has_already_appeared = true
	print("APPEARED ON SCREEN EAGLE.")
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_eagle_cry_sound > eagle_cry_interval:
		last_eagle_cry_sound = current_time
		eagle_cry.play()
		
func try_play_swoosh():
	if not has_already_appeared:
		return
	var current_time = Time.get_ticks_msec() / 1000.0
	#print("play eagle 1")
	if current_time - last_eagle_swoosh_sound > eagle_swoosh_interval:
		#print("play eagle 2")
		last_eagle_swoosh_sound = current_time
		var rnd_int = randi_range(0, 1)
		if rnd_int == 1:
			eagle_swoosh_1.play()
		else:
			eagle_swoosh_2.play()
			

func _on_eagle_defeated() -> void:
	print("Eagle caught! Dropping Food!")
	
	var tween = create_tween()
	# Fall out of the sky and spin
	tween.tween_property(self, "global_position", global_position + Vector2(0, 400), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", rotation + PI*3, 1.0)
	tween.tween_callback(self.queue_free)
	
	# TODO: Spawn your food dropping logic here or use a GameManager task!
