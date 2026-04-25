extends Area2D

@export var blocker: StaticBody2D 

# --- NOVÉ: Propojení s příběhem ---
#@export var dialogue_on_trigger: String = "" 
@export var target_id_to_activate: String = ""

func _ready() -> void:
	if blocker:
		blocker.visible = false
		blocker.process_mode = Node.PROCESS_MODE_DISABLED 
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: # (Pokud používáte 3D, přepiš na CharacterBody3D)
		activate_blocker()
		
		set_deferred("monitoring", false)

func activate_blocker() -> void:
	if blocker:
		blocker.visible = true
		blocker.process_mode = Node.PROCESS_MODE_INHERIT
		
		# --- NOVÉ: Komunikace s hrou ---
		# Spustíme dialogový text
	#	if dialogue_on_trigger != "":
		#	GameManager.trigger_dialogue(dialogue_on_trigger)
			
		# Můžeme i ručně zaktivovat ten StampGoal na překážce
	#	if target_id_to_activate != "":
	#		GameManager.stamp_target_activated.emit(target_id_to_activate)
