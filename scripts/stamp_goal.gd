extends CollisionObject2D 
class_name StampGoal

signal stamped(current: int, required: int)
signal completed()

# --- LOGIKA ÚKOLU ---
@export var target_id: String = "" 
@export var required_hits: int = 1 
@export var always_active: bool = false # Skvělé pro trash-moby, které můžeš rozbít kdykoliv!

# --- VIZUÁL A FYZIKA ---
@export_group("Visuals & Physics")
@export var default_texture: Texture2D
@export var stamped_texture: Texture2D 
@export var rejected_texture: Texture2D
@export var stamped_scale_modifier: float = 1.0
@export var rejected_scale_modifier: float = 1.0
@export var linked_barricade: CollisionShape2D
@export var enables_barricade_instead: bool = false # Toggles if this STAMP builds a physical wall instead of breaking one!
@export var dialogue_on_destroy: String = "" 

@onready var indicator = get_node_or_null("Indicator")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var is_active: bool = false
var current_hits: int = 0
var is_destroyed: bool = false
var base_scale: Vector2 = Vector2.ONE

# --- MARTIN A AUDIO ---
@export_group("Audio")
enum MaterialType { WOOD, IRON, NO_SOUND, ROMAN, ELEPHANT, TREE, BRIDGE }
@export var current_material: MaterialType = MaterialType.WOOD
@onready var wood_1_sound: AudioStreamPlayer = $SoundManager/Wood1Sound
@onready var wood_2_sound: AudioStreamPlayer = $SoundManager/Wood2Sound
@onready var iron_1_sound: AudioStreamPlayer = $SoundManager/Iron1Sound
@onready var iron_2_sound_2: AudioStreamPlayer = $SoundManager/Iron2Sound2
@onready var big_destruction: AudioStreamPlayer = $SoundManager/BigDestruction
@onready var iron_crush_1: AudioStreamPlayer = $SoundManager/IronCrush1
@onready var iron_crush_2: AudioStreamPlayer = $SoundManager/IronCrush2
@export var roman_shouting_sounds: Array[AudioStreamPlayer]
@onready var elephant_trumpet: AudioStreamPlayer = $SoundManager/ElephantTrumpet
@onready var elephant_squashed: AudioStreamPlayer = $SoundManager/ElephantSquashed
@onready var elephant_burned: AudioStreamPlayer = $SoundManager/ElephantBurned
@export var elephant_wait_time_1: float = 1.0
@export var elephant_wait_time_2: float = 1.0


func _ready() -> void:
	base_scale = scale
	
	if always_active:
		is_active = true
		
	if indicator and not always_active: 
		indicator.hide()
	
	if sprite and default_texture:
		sprite.texture = default_texture
		
	# If this is a building component, the barricade must start completely disabled!
	if linked_barricade and enables_barricade_instead:
		linked_barricade.set_deferred("disabled", true)
		
	GameManager.stamp_target_activated.connect(_on_target_activated)
	input_event.connect(_on_input_event)
	GameManager.hand_clicked.connect(_on_hand_clicked)

func _on_target_activated(activated_ids: String) -> void:
	if is_destroyed or always_active:
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
		
		# Trash-mob units should NEVER progress the main story sequence even if they have an ID!
		if not always_active:
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
		sprite.scale *= stamped_scale_modifier
		
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	if linked_barricade:
		if enables_barricade_instead:
			linked_barricade.set_deferred("disabled", false)
		else:
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
		sprite.scale *= rejected_scale_modifier
		
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _play_hit_animation() -> void:
	var tween = create_tween()
	scale = base_scale * 0.7
	tween.tween_property(self, "scale", base_scale, 0.15).set_trans(Tween.TRANS_BOUNCE)
	
func play_destruction_sound() -> void:
	if not GameManager.should_play_dream_sounds:
		return
	#var rnd_sound = randi_range(0, 1)
	
	if current_material == MaterialType.WOOD:
		wood_1_sound.play()
	if current_material == MaterialType.IRON:
		iron_1_sound.play()
	if current_material == MaterialType.ROMAN:
		iron_crush_2.play()
		play_two_random_shouts()
	if current_material == MaterialType.ELEPHANT:
		play_elephant_death_sequence()
		

func play_elephant_death_sequence():
	#print("ELEPHANT DEATH SEQUENCE")

	#await get_tree().create_timer(0.5).timeout
	#elephant_squashed.play()
	#await get_tree().create_timer(0.2).timeout
	#elephant_trumpet.stop()
	#print("elephant_trumpet")
	#await get_tree().create_timer(0.2).timeout
	#print("elephant_burning1")
	##elephant_burned.play()
	#print("elephant_burning2")
	elephant_trumpet.play()
	await get_tree().create_timer(0.6).timeout
	elephant_burned.play()
	print("elephant_burning1")
	
	

func play_two_random_shouts():
	if not GameManager.should_play_dream_sounds:
		return
	if roman_shouting_sounds.size() < 2:
		return

	var shuffled_list = roman_shouting_sounds.duplicate()
	shuffled_list.shuffle()

	shuffled_list[0].play()
	shuffled_list[1].play()
