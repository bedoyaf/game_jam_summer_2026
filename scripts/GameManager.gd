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
signal hand_clicked()

# Black cloud signals
signal cloud_start
signal cloud_covers_whole_screen
signal cloud_is_gone

# Battle signals
signal battle_started
signal battle_ended

# SYSTÉM ÚKOLŮ (Tasks)

var dream_character_position: Vector2 = Vector2(0, 0)
var current_task_index: int = 0
var task_list: Array[Dictionary] = [
	{
		"id": "tree_blocking",
		"desc": "Cestu blokuje strom. Zbav se ho razítkem.",
		"target_group": "obstacle1",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "elephant_decisions",
		"desc": "Vyber si cestu: Zleva nebo zprava?",
		"target_group": "path_A_1,path_B_1",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "river_bridge",
		"desc": "Cesta je stržená. Postav most.",
		"target_group": "bridge_stamps",
		"required_stamps": 4,
		"current_stamps": 0
	},
	{
		"id": "food_eagle",
		"desc": "Chyť kroužícího orla se zásobami!",
		"target_group": "eagle",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "galic_blockade",
		"desc": "Galové bourají blokádu. Orazítkuj ji pryč.",
		"target_group": "obstacle2",
		"required_stamps": 3,
		"current_stamps": 0
	},
	{
		"id": "gauls_decision",
		"desc": "Křižovatka před Galy. Zvol postup.",
		"target_group": "path_A_2,path_B_2",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "ambush_from_behind",
		"desc": "Léčka zezadu! Zbav se útočníků.",
		"target_group": "ambush",
		"required_stamps": 1,
		"current_stamps": 0
	},
	{
		"id": "final_battle",
		"desc": "Finální útok: Potlač odpor Římanů!",
		"target_group": "battle",
		"required_stamps": 1,
		"current_stamps": 0
	}
]

# --- GLOBÁLNÍ COOLDOWN A SDÍLENÉ RAZÍTKO ---
var last_stamp_msec: int = 0
var stamp_cooldown_msec: int = 350 
var current_stamp_rotation: float = 0.0 # NOVÉ: Sem si uložíme rotaci pro daný klik

# --- AUDIO ZVUKY RAZÍTEK ---
var stamp_sounds: Array[AudioStream] = []
var stamp_audio_player: AudioStreamPlayer

func is_stamp_allowed() -> bool:
	var now = Time.get_ticks_msec()
	if now - last_stamp_msec <= 50:
		return true 
	if now - last_stamp_msec >= stamp_cooldown_msec:
		return true
	return false
	
#func _process(_delta):
	#if Input.is_action_just_pressed("skip"):
		#battle_started.emit()

func record_stamp() -> void:
	var now = Time.get_ticks_msec()
	
	# Zkontrolujeme, jestli je to opravdu nové kliknutí 
	# (a ne jen ten samý klik, co se ve zlomku milisekundy propadl na druhý papír)
	if now - last_stamp_msec > 50:
		# Vygenerujeme rotaci a zatřeseme kamerou POUZE JEDNOU!
		current_stamp_rotation = randf_range(-0.3, 0.3)
		camera_shake.emit(25.0)
		
		if stamp_sounds.size() > 0:
			stamp_audio_player.stream = stamp_sounds.pick_random()
			stamp_audio_player.play()
		
	last_stamp_msec = now

func _ready() -> void:
	# Inicializace zvukového přehrávače
	stamp_audio_player = AudioStreamPlayer.new()
	add_child(stamp_audio_player)
	
	# Načtení 6 zvukových souborů
	for i in range(1, 7):
		stamp_sounds.append(load("res://assets/sounds/Stamps/stamp%d.wav" % i))

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
		print("Konec hry / Všechny úkoly splněny! Spouštím závěrečnou scénu...")
		# UPDATE THIS PATH TO WHEREVER YOU SAVE YOUR ENDING SCENE!
		return

	var task = task_list[current_task_index]
	task_updated.emit(task["id"], task["desc"])
	stamp_target_activated.emit(task["target_group"])
	print("Nový úkol: ", task["desc"])
	
	# Pokusí se zahrát úvodní text k tomuto konkrétnímu tasku (pokud existuje v JSONu)
	trigger_dialogue(task["id"] + "_beginning")

func register_stamp_hit(target_group: String) -> void:

	stamp_placed.emit(target_group)

	if current_state != GameState.DREAM_WORLD:
		return

	var current_task = task_list[current_task_index]

	# Důležité: Split(',') povoluje kombo jako "path_A_1,path_B_1"
	if target_group in current_task["target_group"].split(","):
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
