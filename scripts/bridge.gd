extends StaticBody2D

@export var main_collider: CollisionShape2D

var planks: Array[StampGoal] = []
var planks_completed: int = 0

func _ready() -> void:
	# Fallback if you forget to assign it in the inspector
	if not main_collider:
		main_collider = get_node_or_null("CollisionShape2D")
		
	# Dynamically check for all child Component Goals and link them!
	for child in get_children():
		if child is StampGoal:
			planks.append(child)
			print(child)
			# Ensure it takes exactly 1 hit to build this specific piece
			child.required_hits = 1
			child.completed.connect(_on_plank_completed)
	
	planks.reverse()

	# SEKVENCE (SEQUENCE) LOGIC: Hide future planks so you must build from start to finish
	for i in range(planks.size()):
		var plank = planks[i]
		if i == 0:
			pass # First one stays fully active
		else:
			# Hide visually and physically disable the rest
			plank.hide()
			plank.is_active = false
			if plank.collision_shape:
				plank.collision_shape.set_deferred("disabled", true)
			
	print("Bridge initialized. Waiting for ", planks.size(), " planks to be built in sequence.")

func _on_plank_completed() -> void:
	planks_completed += 1
	
	if planks_completed < planks.size():
		# It's time to reveal the next plank in the sequence!
		var next_plank = planks[planks_completed]
		
		# Turn its visuals and physics back on
		next_plank.show()
		next_plank.is_active = true # Guarantee it's active
		if next_plank.indicator:
			next_plank.indicator.show()
			
		if next_plank.collision_shape:
			next_plank.collision_shape.set_deferred("disabled", false)
	else:
		_open_bridge()

func _open_bridge() -> void:
	print("Bridge complete! Removing invisible chasm wall.")
	
	# Disable the main large collision shape that blocks the player from walking over the hole
	if main_collider:
		main_collider.set_deferred("disabled", true)
		
	# A tiny bit of juice: shake the camera when the physical bridge finishes
	GameManager.camera_shake.emit(10.0)
