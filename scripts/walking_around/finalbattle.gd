extends Node2D

@export var time : float = 9
@export var fade_rect: ColorRect

var active := false
var tween: Tween
var tween2: Tween

func _ready():
	fade_rect.modulate.a = 0.0
func start_end_dream():
	if active:
		return
	
	active = true
	
	# Zrušili jsme přepnutí do stavu TRANSITION, protože to tvrdě blokovalo pohyb a boj s bossem!
	# GameManager.start_end_dream_transition()
	
	print("Fading")
	
	# reset
	fade_rect.modulate.a = 0.0
	
	# kill old tween pokud existuje
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, time) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN)
	
	tween.tween_callback(_on_fade_complete)
func _on_fade_complete():
	if tween2:
		tween2.kill()
	
	tween2 = create_tween()
	tween2.tween_property(fade_rect, "modulate:a", 0.0, 1) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN)
	
	set_dream_level_smooth(0.0)
	GameManager.should_play_dream_sounds = false
	GameManager.battle_ended.emit()
	
var dream_controller = null
var dream_tween: Tween

func set_dream_level_smooth(target: float, duration: float = 2.0):
	if dream_tween:
		dream_tween.kill()
	GameManager.endscene._stamp_all_papers()
	var start_value = GameManager.dreamcontroller.dream_level
	
	dream_tween = create_tween()
	dream_tween.tween_method(_apply_dream_level, start_value, target, duration)
	dream_tween.finished.connect(GameManager.play_end_cutscene)
func _apply_dream_level(value: float):
	GameManager.dreamcontroller.dream_level = value
