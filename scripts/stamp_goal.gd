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
@export var linked_barricade: CollisionShape2D
@export var enables_barricade_instead: bool = false # Toggles if this STAMP builds a physical wall instead of breaking one!
@export var dialogue_on_destroy: String = "" 

@onready var indicator = get_node_or_null("Indicator")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var is_active: bool = false
var current_hits: int = 0
var is_destroyed: bool = false

func _ready() -> void:
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
	if indicator: 
		indicator.hide() 
	
	if sprite and stamped_texture:
		sprite.texture = stamped_texture
		
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
		
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _play_hit_animation() -> void:
	var tween = create_tween()
	scale = Vector2(0.8, 0.8)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
