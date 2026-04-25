extends StaticBody2D

@export var destroyed_texture: Texture2D

@onready var main_sprite = $Sprite2D
@onready var main_collision = $CollisionShape2D


func _on_rock_hit(current_hits: int, required_hits: int) -> void:
	# Create a small tween shrink/grow effect on the whole rock!
	var tween = create_tween()
	scale = Vector2(0.9, 0.9)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)

func _on_obstacle_destroyed() -> void:
	print("Obstacle Destroyed! Disabling physical walls...")
	
	# 1. Disable the main physics wall that blocks Hannibal
	main_collision.set_deferred("disabled", true)
	
	# 2. Change the big sprite
	if destroyed_texture:
		main_sprite.texture = destroyed_texture
		
	# 3. Optional: Play a particle pop or AnimationPlayer here!
	# $Particles2D.emitting = true
	# $AnimationPlayer.play("crumble_away")
