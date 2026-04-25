extends Node

@export var decision1 : StaticBody2D
@export var decision2 : StaticBody2D 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(decision1.is_stamped):
		decision2.disabled = true
	elif(decision2.is_stamped):
		decision1.disabled = true
