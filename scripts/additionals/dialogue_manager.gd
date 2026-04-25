extends Control

const DIALOGUE_PATH = "res://resources//dialogues.json"

var dialogue_data: Dictionary = {}
@onready var dialogue_ui = $DialogueUI

func _ready() -> void:
	load_dialogues()
	GameManager.dialogue_triggered.connect(_on_dialogue_triggered)


func load_dialogues():
	if not FileAccess.file_exists(DIALOGUE_PATH):
		print("Chyba: JSON soubor s dialogy nenalezen!")
		return

	var file = FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	
	# Godot 4 JSON parsování
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		dialogue_data = json.data
	else:
		print("Chyba při čtení JSONu: ", json.get_error_message())

func _on_dialogue_triggered(dialogue_id: String) -> void:
	print("Objekt přijal signál k dialogu: ", dialogue_id)
	play_dialogue(dialogue_id)

func play_dialogue(key: String):
	if not dialogue_data.has(key):
		print("Missing dialogue:", key)
		return
	
	var raw = dialogue_data[key]
	var lines: Array[String] = []
	
	if raw is Array:
		for item in raw:
			lines.append(str(item))
	else:
		lines.append(str(raw))  # fallback
	
	dialogue_ui.show_dialogue(lines)
