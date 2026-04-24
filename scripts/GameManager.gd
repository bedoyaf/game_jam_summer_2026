extends Node

enum GameState {
	PAPERWORK,   # Fáze 1: Klikání na papíry
	TRANSITION,  # Fáze 2: Prolínání shaderů
	DREAM_WORLD  # Fáze 3: Top-down pobíhání
}

var current_state: GameState = GameState.PAPERWORK

## SIGNÁLY (Události, na které mohou reaovat jiné scény - UI, Hráč, Shadery)
signal state_changed(new_state: GameState)
signal task_updated(task_id: String, description: String)
signal dialogue_triggered(dialogue_id: String)
signal stamp_target_activated(target_group: String) # Aktivuje hitboxy pro razítko
signal stamp_placed(target_id: String)

## SYSTÉM ÚKOLŮ (Tasks)
var current_task_index: int = 0
var task_list: Array[Dictionary] = [
	{
		"id": "intro_cave",
		"desc": "Prozkoumej snovou jeskyni.",
		"target_group": "none",
		"required_stamps": 0,
		"current_stamps": 0
	},
	{
		"id": "build_bridge",
		"desc": "Cesta je stržená. Postav most pomocí razítek (Ano/Ne).",
		"target_group": "bridge_stamps", # Skupina uzlů, kam se dá razítkovat
		"required_stamps": 4,            # Potřebujeme 4 razítka k dokončení
		"current_stamps": 0
	},
	{
		"id": "feed_army",
		"desc": "Vojáci hladoví. Orazítkuj slona pro 'přerozdělení' zásob.",
		"target_group": "elephant_stamp",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "defeat_romans",
		"desc": "Zasněžená hlídka! Rozrazítkuj protivníky.",
		"target_group": "enemy_stamps",
		"required_stamps": 3,
		"current_stamps": 0
	}
]

func _ready() -> void:
	# Při startu hry nastavíme výchozí stav
	change_state(GameState.PAPERWORK)

# --- SPRÁVA STAVŮ HRY ---

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	state_changed.emit(current_state)
	
	match current_state:
		GameState.PAPERWORK:
			print("Začíná byrokracie...")
		GameState.TRANSITION:
			print("Zapínám snové shadery...")
			# Zde by se mohl spustit timer, který po X sekundách přepne na DREAM_WORLD
		GameState.DREAM_WORLD:
			print("Vítej ve snu, Hannibale.")
			start_dream_tasks()


# --- SPRÁVA SNOVÝCH ÚKOLŮ ---
func start_dream_tasks() -> void:
	current_task_index = 0
	_update_current_task()

func _update_current_task() -> void:
	if current_task_index >= task_list.size():
		print("Konec hry / Všechny úkoly splněny!")
		return
	
	var task = task_list[current_task_index]
	task_updated.emit(task["id"], task["desc"])
	stamp_target_activated.emit(task["target_group"])
	print("Nový úkol: ", task["desc"])

func register_stamp_hit(target_group: String) -> void:
	# 1. Okamžitě rozešleme do světa informaci, že padlo razítko
	# (Tohle vyřeší tvůj error a probudí to PaperWorkPhase skript)
	stamp_placed.emit(target_group)
	
	# 2. Původní logika pro úkoly ve snovém světě
	if current_state != GameState.DREAM_WORLD:
		return
		
	var current_task = task_list[current_task_index]
	
	if current_task["target_group"] == target_group:
		current_task["current_stamps"] += 1
		print("Razítko položeno! (", current_task["current_stamps"], "/", current_task["required_stamps"], ")")
		
		if current_task["current_stamps"] >= current_task["required_stamps"]:
			complete_current_task()
			
func complete_current_task() -> void:
	var task_id = task_list[current_task_index]["id"]
	print("Úkol splněn: ", task_id)
	
	# Můžeš zde spustit dialog v závislosti na splněném úkolu
	trigger_dialogue(task_id + "_completed")
	
	current_task_index += 1
	_update_current_task()

# --- DIALOGY ---

func trigger_dialogue(dialogue_id: String) -> void:
	dialogue_triggered.emit(dialogue_id)
	print("Přehrávám dialog: ", dialogue_id)
