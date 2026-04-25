extends CollisionObject2D 
class_name StampGoal

# --- LOGIKA ÚKOLU ---
@export var target_id: String = "" 
@export var required_hits: int = 1 

# --- VIZUÁL A FYZIKA ---
@export_group("Visuals & Physics")
@export var default_texture: Texture2D
@export var stamped_texture: Texture2D 
@export var dialogue_on_destroy: String = "" 

@onready var indicator = get_node_or_null("Indicator")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var is_active: bool = false
var current_hits: int = 0
var is_destroyed: bool = false

func _ready() -> void:
	if indicator: 
		indicator.hide()
	
	if sprite and default_texture:
		sprite.texture = default_texture
		
	GameManager.stamp_target_activated.connect(_on_target_activated)
	input_event.connect(_on_input_event)

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

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_active or is_destroyed:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GameManager.is_stamp_allowed():
			GameManager.record_stamp() 
			
			current_hits += 1
			GameManager.register_stamp_hit(target_id) 
			
			_play_hit_animation()
			
			if current_hits >= required_hits:
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
		
	if dialogue_on_destroy != "":
		GameManager.trigger_dialogue(dialogue_on_destroy)

func _play_hit_animation() -> void:
	var tween = create_tween()
	scale = Vector2(0.8, 0.8)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
