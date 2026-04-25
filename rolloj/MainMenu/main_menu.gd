extends Node2D

var button_type

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
		get_tree().change_scene_to_file("res://main_menu.tscn")
	elif button_type == "options":
		get_tree().change_scene_to_file("res://main_menu.tscn")
