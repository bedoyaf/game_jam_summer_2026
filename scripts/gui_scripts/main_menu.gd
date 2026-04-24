extends Control

@export var game_scene_path: String
@export var options_scene_path: String


func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_scene_path)
	
	
func _on_options_button_pressed():
	get_tree().change_scene_to_file(options_scene_path)
	
	
func _on_quit_button_pressed():
	get_tree().quit()
