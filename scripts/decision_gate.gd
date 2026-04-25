extends StaticBody2D

var options: Array[StampGoal] = []
var decision_made: bool = false

func _ready() -> void:
	# Dynamically check for all child Component Goals and link them!
	for child in get_children():
		if child is StampGoal:
			options.append(child)
			# We intentionally don't touch required_hits here so you can seamlessly set it per-goal in the inspector!
			child.completed.connect(_on_decision_made.bind(child))
			
	print("Decision Gate initialized with ", options.size(), " branching options.")

func _on_decision_made(chosen: StampGoal) -> void:
	if decision_made:
		return
	decision_made = true
	
	print("Decision locked: ", chosen.target_id)
		
	# Trigger the custom rejection logic on all the un-chosen stamps
	for child in options:
		if child != chosen:
			child.lock_as_rejected()
			
	# A tiny bit of juice: shake the camera
	GameManager.camera_shake.emit(10.0)
