extends Area2D

@export var blocker: StaticBody2D 

func _ready() -> void:
	if blocker:
		blocker.visible = false
		blocker.process_mode = Node.PROCESS_MODE_DISABLED # Úplně uzel vypne (včetně kolizí)
	
	# Propojení signálu
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Kontrola, jestli do oblasti vlezl hráč
	if body is CharacterBody2D:
		activate_blocker()

func activate_blocker() -> void:
	if blocker:
		blocker.visible = true
		# Zapne blocker zpět do hry
		blocker.process_mode = Node.PROCESS_MODE_INHERIT
