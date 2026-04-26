extends CollisionObject2D 
class_name StampGoal

signal stamped(current: int, required: int)
signal completed()

# --- LOGIKA ÚKOLU ---
@export var target_id: String = "" 
@export var required_hits: int = 1 

# --- VIZUÁL A FYZIKA ---
@export_group("Visuals & Physics")
@export var default_texture: Texture2D
@export var stamped_texture: Texture2D 
@export var rejected_texture: Texture2D
@export var linked_barricade: CollisionShape2D
@export var dialogue_on_destroy: String = "" 

@onready var indicator = get_node_or_null("Indicator")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var is_active: bool = false
var current_hits: int = 0
var is_destroyed: bool = false

# --- MARTIN A AUDIO ---
@export_group("Audio")
enum MaterialType { WOOD, IRON, NO_SOUND }
@export var current_material: MaterialType = MaterialType.WOOD
@onready var wood_1_sound: AudioStreamPlayer2D = $SoundManager/Wood1Sound
@onready var wood_2_sound: AudioStreamPlayer2D = $SoundManager/Wood2Sound
@onready var iron_1_sound: AudioStreamPlayer2D = $SoundManager/Iron1Sound
@onready var iron_2_sound_2: AudioStreamPlayer2D = $SoundManager/Iron2Sound2


func _ready() -> void:
	if indicator: 
		indicator.hide()
	
	if sprite and default_texture:
		sprite.texture = default_texture
		
	GameManager.stamp_target_activated.connect(_on_target_activated)
	input_event.connect(_on_input_event)
	GameManager.hand_clicked.connect(_on_hand_clicked)

func _on_target_activated(activated_ids: String) -> void:
	if is_destroyed:
		return

		
	if target_id in activated_ids.split(","):
		is_active = true
		if indicator: 
			indicator.show()
	else:
		is_active = false
		if indicator: 
			indicator.hide()

func on_stamp() -> void:
	print("STAMP FROM HAND COMPONENT")
	_process_stamp()

func _on_hand_clicked() -> void:
	if not is_active or is_destroyed:
		return
	
	# Because we evaluate from our OWN World2D, this perfectly bypasses SubViewport isolation!
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	for item in results:
		var collider = item.collider
		# Strictly check if the click hit THIS exact component's shape
		if collider == self:
			on_stamp()
			break

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("CLICK FROM INPUT EVENT")
		_process_stamp()

func _process_stamp() -> void:
	if not is_active or is_destroyed:
		return
		
	if GameManager.is_stamp_allowed():
		GameManager.record_stamp() 
		
		current_hits += 1
		stamped.emit(current_hits, required_hits)
		GameManager.register_stamp_hit(target_id) 
		
		_play_hit_animation()
		
		if current_hits >= required_hits:
			completed.emit()
			_destroy_obstacle()

func _destroy_obstacle() -> void:
	is_destroyed = true
	is_active = false
	
	play_destruction_sound()

	if indicator: 
		indicator.hide() 
	
	if sprite and stamped_texture:
		sprite.texture = stamped_texture
		
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	if linked_barricade:
		linked_barricade.set_deferred("disabled", true)
		
	if dialogue_on_destroy != "":
		GameManager.trigger_dialogue(dialogue_on_destroy)

func lock_as_rejected() -> void:
	is_destroyed = true
	is_active = false
	if indicator: 
		indicator.hide() 
	
	if sprite and rejected_texture:
		sprite.texture = rejected_texture
		
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _play_hit_animation() -> void:
	var tween = create_tween()
	scale = Vector2(0.8, 0.8)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
	
func play_destruction_sound() -> void:
	#var rnd_sound = randi_range(0, 1)
	
	if current_material == MaterialType.WOOD:
		wood_1_sound.play()
	if current_material == MaterialType.IRON:
		iron_1_sound.play()
