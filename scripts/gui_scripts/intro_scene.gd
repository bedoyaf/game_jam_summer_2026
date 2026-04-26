extends Control

var black_rect: ColorRect

func _ready() -> void:
	# Výpočtem vytvoříme černo-černou plachtu, která překryje absolutně všechno na obrazovce
	black_rect = ColorRect.new()
	black_rect.color = Color.BLACK
	black_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_rect.z_index = 4096 # Nastaveno tak, aby to bylo zaručeně úplně nahoře
	add_child(black_rect)
	
	# Plynulý nástup: Rozplyneme černé pozadí do průhledna přes 1.5s, čímž odhalíme scénu
	var tween = create_tween()
	tween.tween_property(black_rect, "modulate:a", 0.0, 1.5)
	tween.tween_callback(_start_dialogue)
	
func _start_dialogue() -> void:
	# Schováme černý obdélník, abychom šetřili výkon, když je průhledný
	black_rect.hide()
	
	# Napojíme se na nově vytvořený signál, abychom bezpečně věděli, 
	# kdy se hráč prokecá dialogem až na samotný konec a panel se schová
	if not GameManager.dialogue_finished.is_connected(_on_dialogue_finished):
		GameManager.dialogue_finished.connect(_on_dialogue_finished)
	
	# DOPLŇ DO JSONU: Tenhle klíč "intro_scene_beginning"
	GameManager.trigger_dialogue("intro_scene_beginning")

func _on_dialogue_finished() -> void:
	# Hráč všechno přečetl a zmáčknul klávesu "E" !
	GameManager.dialogue_finished.disconnect(_on_dialogue_finished)
	
	# Další plynulá tmačka - vrátíme plachtu
	black_rect.show()
	var tween = create_tween()
	tween.tween_property(black_rect, "modulate:a", 1.0, 1.5)
	tween.tween_callback(_go_to_game)

func _go_to_game() -> void:
	# Fyzicky načteme papírovací scénu! 
	# (Pokud jí máš v jiné složce než scenes/MainScene.tscn, pouze tady ten řádek oprav)
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
