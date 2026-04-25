extends Node2D

@export var paper_groups: Array[Node2D]
var current_paper_index: int = 0

func _ready() -> void:
	GameManager.stamp_placed.connect(_on_stamp_placed)
	activate_current_paper()

func activate_current_paper() -> void:
	if current_paper_index < paper_groups.size():
		var targets = "paper_" + str(current_paper_index) + "_yes,paper_" + str(current_paper_index) + "_no"
		GameManager.stamp_target_activated.emit(targets)
		
		GameManager.trigger_dialogue("dialog_paper_" + str(current_paper_index))
	else:
		print("Všechny papíry orazítkovány! Přechod do snu...")
		GameManager.change_state(GameManager.GameState.TRANSITION)

func _on_stamp_placed(target_id: String) -> void:
	var expected_prefix = "paper_" + str(current_paper_index)
	
	if target_id.begins_with(expected_prefix):
		var paper = paper_groups[current_paper_index]
		
		# Místo schování zavoláme animaci odletu
		if paper.has_method("fly_away"):
			paper.fly_away()
		else:
			paper.hide() # Pojistka pro případ, že funkce neexistuje
		
		current_paper_index += 1
		activate_current_paper()
