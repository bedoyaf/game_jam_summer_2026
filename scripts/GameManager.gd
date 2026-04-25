extends Node

enum GameState {
	PAPERWORK,   

	TRANSITION,  

	DREAM_WORLD  

}

var current_state: GameState = GameState.PAPERWORK

# SIGNÁLY (Události, na které mohou reaovat jiné scény - UI, Hráč, Shadery)

signal state_changed(new_state: GameState)
signal task_updated(task_id: String, description: String)
signal dialogue_triggered(dialogue_id: String)
signal stamp_target_activated(target_group: String) 

signal stamp_placed(target_id: String)
signal camera_shake(intensity: float)

# SYSTÉM ÚKOLŮ (Tasks)

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
		"target_group": "bridge_stamps", 

		"required_stamps": 4,            

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

var last_stamp_msec: int = 0
var stamp_cooldown_msec: int = 350 

func is_stamp_allowed() -> bool:
	var now = Time.get_ticks_msec()

	if now - last_stamp_msec <= 50:
		return true 

	if now - last_stamp_msec >= stamp_cooldown_msec:
		return true

	return false

func record_stamp() -> void:
	last_stamp_msec = Time.get_ticks_msec()

func _ready() -> void:

	change_state(GameState.PAPERWORK)

func _input(event):
	if event.is_action_pressed("debug_action"):
		_debug_trigger()
func _debug_trigger():
	current_task_index += 1

	if current_task_index >= task_list.size():
		current_task_index = 0

	print("DEBUG: přepínám na task:", task_list[current_task_index]["id"])
	_update_current_task()
	complete_current_task()

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

		GameState.DREAM_WORLD:
			print("Vítej ve snu, Hannibale.")
			start_dream_tasks()

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

	stamp_placed.emit(target_group)

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

	trigger_dialogue(task_id + "_completed")

	current_task_index += 1
	_update_current_task()

func trigger_dialogue(dialogue_id: String) -> void:
	dialogue_triggered.emit(dialogue_id)
	print("Přehrávám dialog: ", dialogue_id)
