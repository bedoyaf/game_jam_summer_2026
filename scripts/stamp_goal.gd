extends Area2D # (nebo StaticBody2D)
class_name StampGoal

@export var target_id: String = "" 
@onready var indicator = get_node_or_null("Indicator")
var is_active: bool = false

var is_stamped: bool = false
var disabled: bool = false

# ZDE JE OPRAVA: Místo $Sprite2D se ptáme bezpečně
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	if indicator:
		indicator.hide()
	
	GameManager.stamp_target_activated.connect(_on_target_activated)
	input_event.connect(_on_input_event)
	
# Reakce na GameManager
func _on_target_activated(activated_ids: String) -> void:
	# Pokud už byl tento objekt orazítkován, ignorujeme ho a nezapínáme ho
	if is_stamped or disabled:
		return
		
	if target_id in activated_ids.split(","):
		is_active = true
		if indicator:
			indicator.show()
	else:
		is_active = false
		if indicator:
			indicator.hide()

# Reakce na kliknutí myší
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_active:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Zase se zeptáme na cooldown
		if GameManager.is_stamp_allowed():
			GameManager.record_stamp()
			
			print("Razítko umístěno na: ", target_id)
			is_active = false
			if indicator:
				indicator.hide()
			
			_on_stamp()
			GameManager.register_stamp_hit(target_id)

# Samotný efekt razítka na objektu (Od kamaráda)
func _on_stamp() -> void:
	if is_stamped or disabled:
		return  
	
	is_stamped = true
	disabled = true
	
	# PROFI TRIK: Vypínání kolizí přes call_deferred
	# Godot občas nemá rád, když se vypíná fyzika přesně ve stejný moment, kdy se vyhodnocuje.
	# set_deferred to udělá bezpečně hned na konci aktuálního snímku.
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
