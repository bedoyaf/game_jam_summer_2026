extends Node2D

@export_multiline var content_text: String = "Zde je text papíru...":
	set(value):
		content_text = value
		if is_node_ready():
			_update_label()

@onready var label_3d = $MainText3Dscene/Node3D/Label3D

@export var paper_index: int = 0
@export var stamp_texture: Texture2D 

@onready var stamp_container = $PaperSprite/StampContainer
@onready var paper_area = $WholePaperArea
@onready var goal_yes = $Yes
@onready var goal_no = $No
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:

	goal_yes.target_id = "paper_" + str(paper_index) + "_yes"
	goal_no.target_id = "paper_" + str(paper_index) + "_no"

	_update_label()

	paper_area.input_event.connect(_on_paper_input)

func _update_label() -> void:
	if label_3d:
		label_3d.text = content_text

func _on_paper_input(_viewport, event, _shape_idx):
	# NOVÉ: Pokud už nejsme ve fázi papírování (např. jsme ve snu), ignoruj kliknutí!
	if GameManager.current_state != GameManager.GameState.PAPERWORK:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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

	GameManager.camera_shake.emit(25.0) 

	var tween = create_tween()

	tween.tween_interval(3.0) 

	tween.tween_property(stamp, "modulate:a", 0.0, 4.5)

	tween.tween_callback(stamp.queue_free)

func check_goals(event):

	if goal_yes.is_active and is_mouse_over_area(goal_yes):
		goal_yes._on_input_event(null, event, 0)
	elif goal_no.is_active and is_mouse_over_area(goal_no):
		goal_no._on_input_event(null, event, 0)

func is_mouse_over_area(area: Area2D) -> bool:
	var mouse_pos = get_global_mouse_position()
	for child in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			var extents = child.shape.size / 2

			var rect = Rect2(child.global_position - extents, child.shape.size)
			if rect.has_point(mouse_pos):
				return true
	return false

func fly_away():
	var tween = create_tween()

	tween.tween_interval(1.0) 

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(self, "position:y", position.y - 1200, 0.7)

	tween.parallel().tween_property(self, "rotation", rotation + randf_range(-0.4, 0.4), 0.7)

	tween.tween_callback(queue_free)
	
	#await get_tree().create_timer(2.0).timeout
	if audio_stream_player_2d != null:
		print("SOUND 1")
		await get_tree().create_timer(1.0).timeout
		audio_stream_player_2d.play()
		print("SOUND 2")
