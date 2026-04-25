extends Control

@export var game_scene_path: String
@export var options_scene_path: String
@export var await_time: float = 0.2
@onready var floating_papers_container: Node2D = $FloatingPapersContainer

func _on_start_button_pressed():
	await get_tree().create_timer(await_time).timeout
	get_tree().change_scene_to_file(game_scene_path)
	
	
func _on_options_button_pressed():
	await get_tree().create_timer(await_time).timeout
	get_tree().change_scene_to_file(options_scene_path)
	
	
func _on_quit_button_pressed():
	await get_tree().create_timer(await_time).timeout
	get_tree().quit()
	
