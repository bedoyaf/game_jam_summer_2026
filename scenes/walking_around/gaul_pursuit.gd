extends Node2D

@export var wall: Node2D
@export var ambush_guards: StaticBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		wall.show()
		print("wall shown")
		
		# 1. Get the CollisionShape2D that lives inside your StaticBody2D
		var collider = ambush_guards.get_node("CollisionShape2D")
		
		# 2. Safely tell the physics engine to turn it on
		collider.set_deferred("disabled", false)
