extends Control


signal change_dream_level(new_level: float)


func emit_signal_change_dream_level(new_level):
	change_dream_level.emit(new_level)
