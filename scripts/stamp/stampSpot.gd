extends Node2D

@export var default_texture: Texture2D
@export var stamped_texture: Texture2D

var is_stamped: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_visual()


func on_stamp():
	if is_stamped:
		return  # už je označený, ignoruj
	
	is_stamped = true
	_update_visual()
	
	print("STAMPED!")  # debug nebo event


func _update_visual():
	if is_stamped:
		sprite.texture = stamped_texture
	else:
		sprite.texture = default_texture
