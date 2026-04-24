extends Node2D

# Toto číslo změníš v Inspectoru pro každý papír (0, 1, 2, 3...)
@export var paper_index: int = 0

@onready var goal_yes = $Yes 
@onready var goal_no = $No

func _ready() -> void:
	goal_yes.target_id = "paper_" + str(paper_index) + "_yes"
	goal_no.target_id = "paper_" + str(paper_index) + "_no"
