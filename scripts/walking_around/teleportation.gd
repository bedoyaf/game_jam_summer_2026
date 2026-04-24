extends Area2D

# Transform2D v sobě nese pozici, rotaci i měřítko
@export var teleport_target_node: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# 1. Najdeme kameru u hráče
		# Předpokládám, že se uzel jmenuje "Camera2D"
		var camera = body.find_child("Camera2D") as Camera2D
		
		if camera:
			# 2. Vypneme smoothing, aby kamera "nepřilétala" z dálky
			camera.position_smoothing_enabled = false
		
		# 3. Teleport hráče
		body.global_position = teleport_target_node.global_position
		
		# 4. Vynutíme okamžitý update pozice kamery (aby neskočila o snímek později)
		if camera:
			camera.reset_smoothing() # Tato funkce okamžitě přesune kameru na cíl
			
			# 5. Opětovné zapnutí smoothingu (volitelné, pokud ho chceš dál používat)
			# Použijeme call_deferred, aby se to zaplo až po dokončení teleportu
			camera.set_deferred("position_smoothing_enabled", true)
