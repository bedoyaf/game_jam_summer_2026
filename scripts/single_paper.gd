extends Node2D

# --- 1. PROMĚNNÉ PRO TEXT A PERSPEKTIVU ---
@export_multiline var content_text: String = "Zde je text papíru...":
	set(value):
		content_text = value
		if is_node_ready():
			_update_label()

@onready var label_3d = $MainText3Dscene/Node3D/Label3D


# --- 2. PROMĚNNÉ PRO RAZÍTKOVÁNÍ A ÚKOLY ---
@export var paper_index: int = 0
@export var stamp_texture: Texture2D # Přetáhni sem obrázek červeného razítka

@onready var stamp_container = $PaperSprite/StampContainer
@onready var paper_area = $WholePaperArea
@onready var goal_yes = $Yes
@onready var goal_no = $No

func _ready() -> void:
	# 1. Nastavení ID pro cíle
	goal_yes.target_id = "paper_" + str(paper_index) + "_yes"
	goal_no.target_id = "paper_" + str(paper_index) + "_no"
	
	# 2. Při startu nastavíme text z Inspectoru do 3D Labelu
	_update_label()
	
	# 3. Propojíme kliknutí na velkou neviditelnou oblast přes celý papír
	paper_area.input_event.connect(_on_paper_input)

# --- FUNKCE PRO TEXT ---
func _update_label() -> void:
	if label_3d:
		label_3d.text = content_text

# --- FUNKCE PRO RAZÍTKOVÁNÍ ---
func _on_paper_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Zeptáme se GameManageru, jestli nejsme na cooldownu
		if GameManager.is_stamp_allowed():
			GameManager.record_stamp()
			
			var click_pos = get_local_mouse_position()
			create_visual_stamp(click_pos)
			check_goals(event)

func create_visual_stamp(pos: Vector2):
	if not stamp_texture:
		push_warning("Papír nemá přiřazenou 'stamp_texture' v Inspectoru!")
		return
		
	var stamp = Sprite2D.new()
	stamp.texture = stamp_texture
	stamp_container.add_child(stamp)
	stamp.position = stamp_container.to_local(get_global_mouse_position())
	stamp.rotation = randf_range(-0.3, 0.3)
	
	# --- ZDE PŘIDÁME OTŘES KAMERY ---
	# 20.0 je síla otřesu v pixelech. Můžeš zkusit 10.0 pro jemnější, nebo 50.0 pro absolutní chaos!
	GameManager.camera_shake.emit(25.0) 
	
	
	# --- LOGIKA MIZENÍ (FADE OUT) ---
	var tween = create_tween()
	# 1. Počkej 3 sekundy (razítko je vidět)
	tween.tween_interval(3.0) 
	# 2. Během 1.5 sekundy plynule sniž průhlednost (Alpha) na nulu
	tween.tween_property(stamp, "modulate:a", 0.0, 4.5)
	# 3. Jakmile zmizí, úplně ho smaž z paměti
	tween.tween_callback(stamp.queue_free)

func check_goals(event):
	# Protože jsme klikli na obří WholePaperArea, cíle (ANO/NE) možná
	# kliknutí nezaznamenaly. Musíme se jich zeptat manuálně:
	if goal_yes.is_active and is_mouse_over_area(goal_yes):
		goal_yes._on_input_event(null, event, 0)
	elif goal_no.is_active and is_mouse_over_area(goal_no):
		goal_no._on_input_event(null, event, 0)

func is_mouse_over_area(area: Area2D) -> bool:
	# Matematicky ověří, jestli je myš uvnitř obdélníkové kolize daného cíle
	var mouse_pos = get_global_mouse_position()
	for child in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			var extents = child.shape.size / 2
			# Vytvoříme matematický obdélník z kolize a zkontrolujeme, jestli v něm je myš
			var rect = Rect2(child.global_position - extents, child.shape.size)
			if rect.has_point(mouse_pos):
				return true
	return false
	
func fly_away():
	# Vytvoříme Tween pro plynulou animaci
	var tween = create_tween()
	tween.tween_interval(1.0) 
	# Nastavíme typ pohybu (TRANS_BACK způsobí lehké cuknutí před odletem, EASE_IN zrychlení)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	
	# 1. Animace pohybu: pošleme papír o 1200 pixelů nahoru
	tween.tween_property(self, "position:y", position.y - 1200, 0.7)
	
	# 2. Souběžná animace rotace: ať se u toho trochu protočí (náhodně)
	tween.parallel().tween_property(self, "rotation", rotation + randf_range(-0.4, 0.4), 0.7)
	
	# 3. Jakmile animace skončí, uzel úplně smažeme, aby nezabíral paměť
	tween.tween_callback(queue_free)
