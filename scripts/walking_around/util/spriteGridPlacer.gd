@tool
extends Node2D

@export var floor_texture: Texture2D:
	set(value):
		if floor_texture == value:
			return
		floor_texture = value
		_rebuild()

@export var columns: int = 10:
	set(value):
		if columns == value:
			return
		columns = max(1, value) # Zabráníme nule nebo mínusu
		_rebuild()

@export var rows: int = 10:
	set(value):
		if rows == value:
			return
		rows = max(1, value) # Zabráníme nule nebo mínusu
		_rebuild()

@export var tile_size: Vector2 = Vector2(64, 64):
	set(value):
		if tile_size == value:
			return
		tile_size = value
		_rebuild()

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_rebuild")

func _rebuild() -> void:
	if not Engine.is_editor_hint():
		return

	# 1. Vyčistíme staré sprajty
	for child in get_children():
		child.queue_free()

	if not floor_texture:
		return

	# DŮLEŽITÉ: Musíme počkat, až se queue_free() dokončí, 
	# nebo použít jiný způsob mazání, aby se nám staré a nové sprajty nepomíchaly.
	
	for y in range(rows):
		for x in range(columns):
			var sprite = Sprite2D.new()
			sprite.texture = floor_texture
			sprite.centered = false 
			sprite.position = Vector2(x * tile_size.x, y * tile_size.y)
			
			add_child(sprite)
			
			# TENTO ŘÁDEK TO OPRAVÍ:
			# Řekne Godotu, že tento uzel patří do scény a má se uložit/zobrazit ve hře
			sprite.owner = get_tree().edited_scene_root
