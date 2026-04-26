extends Node

@export var papers_parent: NodePath
@export var fade_rect_path: NodePath
@export var final_paper: Node2D
@export var stamps_per_paper := 30

var papers: Array = []
var fade_rect: ColorRect

func set_end_cutscene():
	GameManager.set_end_cutscene(self)

func _ready():
	set_end_cutscene()
	papers = get_node(papers_parent).get_children()
	fade_rect = get_node(fade_rect_path)

	#_start_sequence()


func _start_sequence():
	await _drop_last_paper()
	await _fade_to_black()


# 🧾 1) razítkování všech papírů
func _stamp_all_papers():
	for paper in papers:
		if paper.has_method("spawn_random_stamps"):
			paper.spawn_random_stamps(stamps_per_paper)
		

# 📄 2) dramatický drop posledního papíru
func _drop_last_paper():
	if papers.size() < 2:
		return
	
	var paper = final_paper

	# start nahoře
	paper.position.y -= 800
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(paper, "position:y", paper.position.y + 800, 0.6)

	await tween.finished

func _fade_to_black():
	fade_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 2.0)

	await tween.finished

	print("END")
