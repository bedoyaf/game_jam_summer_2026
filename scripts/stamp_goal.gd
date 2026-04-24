extends Area2D
class_name StampGoal

# Tohle ID přiřadíš v editoru (např. "ANO", "NE", "bridge_stamps", "elephant_stamp")
@export var target_id: String = "" 

@onready var indicator = $Indicator

var is_active: bool = false

func _ready() -> void:
	if indicator:
		indicator.hide()
	
	GameManager.stamp_target_activated.connect(_on_target_activated)
	
	input_event.connect(_on_input_event)

func _on_target_activated(activated_ids: String) -> void:
	if target_id in activated_ids.split(","):
		is_active = true
		if indicator:
			indicator.show()
	else:
		is_active = false
		if indicator:
			indicator.hide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_active:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Razítko umístěno na: ", target_id)
		
		is_active = false
		if indicator:
			indicator.hide()
		
		GameManager.register_stamp_hit(target_id)
