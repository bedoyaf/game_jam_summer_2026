#@tool

extends Node2D

var min_x_speed: float = 10
var max_x_speed: float = 100


var x_speed: float = 5
var y_multiplier_speed: float = 1.5



func _process(delta):
	position.x += x_speed * delta
	position.y += x_speed * y_multiplier_speed * delta

func _on_exit_screen():
	queue_free()
	
