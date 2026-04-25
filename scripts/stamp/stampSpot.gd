extends StaticBody2D

@export var default_texture: Texture2D
@export var stamped_texture: Texture2D

@export var dialogue : String

var is_stamped: bool = false
var disabled: bool = false

@onready var sprite: Sprite2D = $Sprite2D

@onready var collisionShape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_update_visual()


func on_stamp():
	if is_stamped or disabled:
		return  # už je označený, ignoruj
	
	is_stamped = true
	disabled = true
	_update_visual()
	
	print("STAMPED!")  # debug nebo event
	collisionShape.disabled = true


func _update_visual():
	if is_stamped:
		sprite.texture = stamped_texture
	else:
		sprite.texture = default_texture
