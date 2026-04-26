extends CanvasLayer

@onready var label = $Panel/Label
@onready var panel = $Panel

@export var text_speed: float = 0.02  # rychlost psaní (menší = rychlejší)

var lines: Array[String] = []
var current_line_index := 0
var is_typing := false
var skip_requested := false

var dialogue_run_id := 0
var last_append_time := 0

func _ready():
	panel.hide()

func show_dialogue(text: Array[String]):
	var now = Time.get_ticks_msec()
	
	if panel.visible and (now - last_append_time) < 100:
		# Pokud dialogy přijdou na frejmu ZÁROVEŇ (např. 'dokončení úkolu' + hned vzápětí 'nový úkol')
		# zařadíme je přirozeně do fronty
		lines.append_array(text)
	else:
		# Jde o NOVOU událost mnohem později! Hráč zřejmě celou dobu zapomněl mačkat 'E'.
		# Všechny staré nevyzvednuté texty tvrdě vyhodíme a přepíšeme obrazovku tímto aktuálním!
		dialogue_run_id += 1
		lines = text
		current_line_index = 0
		panel.show()
		_show_next_line()
		
	last_append_time = now

func _show_next_line():
	if current_line_index >= lines.size():
		panel.hide()
		GameManager.dialogue_finished.emit()
		return
	
	var line = lines[current_line_index]
	current_line_index += 1
	
	await _type_line(line, dialogue_run_id)

func _type_line(line: String, run_id: int) -> void:
	if run_id != dialogue_run_id:
		return
	label.text = ""
	is_typing = true
	skip_requested = false
	
	for i in line.length():
		if run_id != dialogue_run_id:
			return # Zombie loop abort!
			
		if skip_requested:
			label.text = line
			break
		
		label.text += line[i]
		await get_tree().create_timer(text_speed).timeout
	
	is_typing = false

func _input(event):
	if not panel.visible:
		return
	
	if event.is_action_pressed("skip"): 
		if is_typing:
			skip_requested = true  
		else:
			_show_next_line()      
