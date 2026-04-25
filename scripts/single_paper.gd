extends Node2D

# 1. Definujeme exportovanou proměnnou pro text
# Použijeme @export_multiline, aby se v Inspectoru psalo lépe (víc řádků)
@export_multiline var content_text: String = "Zde je text papíru...":
	set(value):
		content_text = value
		# Tento blok zajistí, že se text aktualizuje i v editoru (pokud máš @tool)
		# nebo hned po načtení scény.
		if is_node_ready():
			_update_label()

@export var paper_index: int = 0

# Odkazy na tvé uzly
@onready var goal_yes = $Yes 
@onready var goal_no = $No
# Cesta k Label3D podle tvého popisu
@onready var label_3d = $SubViewport2/Node3D/Label3D

func _ready() -> void:
	goal_yes.target_id = "paper_" + str(paper_index) + "_yes"
	goal_no.target_id = "paper_" + str(paper_index) + "_no"
	
	# Při startu nastavíme text z Inspectoru do Label3D
	_update_label()

func _update_label() -> void:
	if label_3d:
		label_3d.text = content_text
