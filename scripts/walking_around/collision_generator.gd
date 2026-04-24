extends StaticBody2D

@export var mask: Texture2D
@export var tile_size := 8

func _ready():
	var img = mask.get_image()
	img.decompress()

	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)

			if c.r < 0.5: # zeď
				_add_tile(Vector2(x, y))

func _add_tile(pos: Vector2):
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()

	rect.size = Vector2(tile_size, tile_size)
	shape.shape = rect

	body.position = pos * tile_size
	body.add_child(shape)
	add_child(body)
