extends Control

var button_type
@export var stamp_texture: Texture2D 
@onready var stamp_container = $StampContainer

func _on_start_pressed() -> void:
	button_type = "start"
	$FadeTransition.show()
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")

func _on_options_pressed() -> void:
	button_type = "options"
	$FadeTransition.show()
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
	elif button_type == "options":
		get_tree().change_scene_to_file("res://main_menu.tscn")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("STAMP")
		var click_pos = get_local_mouse_position()
		create_visual_stamp(click_pos)


func create_visual_stamp(pos: Vector2):
	if not stamp_texture:
		push_warning("Papír nemá přiřazenou 'stamp_texture' v Inspectoru!")
		return

	var stamp = Sprite2D.new()
	stamp.texture = stamp_texture
	stamp_container.add_child(stamp)
	stamp.position = stamp_container.to_local(get_global_mouse_position())
	stamp.rotation = randf_range(-0.3, 0.3)
	
	# FORCE the stamp to draw on top of everything!
	stamp.z_index = 19

	GameManager.camera_shake.emit(25.0) 

	var tween = create_tween()

	tween.tween_interval(3.0) 

	tween.tween_property(stamp, "modulate:a", 0.0, 4.5)

	tween.tween_callback(stamp.queue_free)
