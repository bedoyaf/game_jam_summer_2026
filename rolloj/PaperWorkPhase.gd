extends Node2D

@export var paper_groups: Array[Node2D]
var current_paper_index: int = 0

@export var dream_controller: Node 

@export var dream_progression: Dictionary = {
	3: 0.1, 

	4: 0.2, 

	5: 0.99  

}

func _ready() -> void:
		
	$FadeTransition/AnimationPlayer.play("fade_out")

	if dream_controller:
		dream_controller.dream_level = 0.0

	GameManager.stamp_placed.connect(_on_stamp_placed)
	activate_current_paper()

func activate_current_paper() -> void:

	if dream_controller and dream_progression.has(current_paper_index):
		var target_level = dream_progression[current_paper_index]

		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)

		tween.tween_property(dream_controller, "dream_level", target_level, 3.0)
		print("Postup do snu: Úroveň mlhy se zvyšuje na ", target_level)

	if current_paper_index < paper_groups.size():
		var targets = "paper_" + str(current_paper_index) + "_yes,paper_" + str(current_paper_index) + "_no"
		GameManager.stamp_target_activated.emit(targets)
		
		# Vlastní hardcoded spouštěče pro předpřipravené texty
		if current_paper_index == 0:
			GameManager.trigger_dialogue("beginning_beginning")
		elif current_paper_index == 2:
			GameManager.trigger_dialogue("stamped_just_table_beginning")
		elif current_paper_index >= paper_groups.size() - 1:
			GameManager.trigger_dialogue("last_real_stamp_beginning")
			
	else:
		print("Všechny papíry orazítkovány! Přechod do snu...")
		
		GameManager.trigger_dialogue("dream_fade_beginning")
		await get_tree().create_timer(2.0).timeout
		
		# 1. Přepneme do přechodu (shadery už ti jedou z předchozího Tweenu)
		GameManager.change_state(GameManager.GameState.TRANSITION)
		
		GameManager.trigger_dialogue("dream_fade_completed")
		# 2. Počkáme například 2 sekundy (aby měl hráč čas vstřebat vizuál)
		await get_tree().create_timer(1.0).timeout
		
		# 3. ODSTARTUJEME SEN! (Tohle probudí GameManager a pošle první úkol)
		GameManager.change_state(GameManager.GameState.DREAM_WORLD)
		
func _on_stamp_placed(target_id: String) -> void:
	var expected_prefix = "paper_" + str(current_paper_index)

	if target_id.begins_with(expected_prefix):
		var paper = paper_groups[current_paper_index]

		if paper.has_method("fly_away"):
			paper.fly_away()
		else:
			paper.hide() 
			
		# Spouštěče pro chvíli KDY se papír označí razítkem!
		if current_paper_index == 2:
			GameManager.trigger_dialogue("stamped_just_table_completed")
		elif current_paper_index >= paper_groups.size() - 1:
			GameManager.trigger_dialogue("last_real_stamp_completed")

		current_paper_index += 1
		activate_current_paper()
