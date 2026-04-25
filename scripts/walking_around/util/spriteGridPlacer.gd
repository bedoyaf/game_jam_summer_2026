extends Node2D

@export var textures: Array[Texture2D]
@export var columns: int = 10
@export var tile_size: Vector2 = Vector2(64, 64)

func _ready():
	for i in textures.size():
		var sprite = Sprite2D.new()
		sprite.texture = textures[i]
		
		var x = i % columns
		var y = i / columns
		
		sprite.position = Vector2(x * tile_size.x, y * tile_size.y)
		
		add_child(sprite)
