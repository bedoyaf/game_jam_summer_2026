extends AudioStreamPlayer

@export var transition_time: float = 5.0

func _ready():
	GameManager.connect("battle_started", _on_battle_started)
	GameManager.connect("battle_ended", _on_battle_ended)
	# Ensure we start at silence if the node is set to auto-play or triggered early
	volume_db = -80


func _on_battle_started():
	# Reset volume to silent before starting the fade-in
	volume_db = -80
	play()
	
	var tween = create_tween()
	# Transition volume_db to 0 (normal volume) over transition_time seconds
	tween.tween_property(self, "volume_db", 0.0, transition_time).set_trans(Tween.TRANS_SINE)
	
	
func _on_battle_ended():
	var tween = create_tween()
	# Transition volume_db back to -80 (silence)
	tween.tween_property(self, "volume_db", -80.0, transition_time).set_trans(Tween.TRANS_SINE)
	# Stop the player entirely once the fade-out is finished
	tween.tween_callback(stop)
