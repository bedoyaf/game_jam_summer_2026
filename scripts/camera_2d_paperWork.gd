extends Camera2D

var shake_intensity: float = 0.0
@export var shake_decay: float = 18.0 # Jak rychle se kamera uklidní (větší číslo = rychlejší utlumení)

func _ready():
	# Napojíme kameru na globální signál
	GameManager.camera_shake.connect(apply_shake)

func apply_shake(intensity: float):
	# Nastavíme sílu. Pokud už se třepe, přidáme k tomu novou sílu (pro zuřivé razítkování!)
	shake_intensity = max(shake_intensity, intensity)

func _process(delta: float) -> void:
	if shake_intensity > 0.1:
		# Postupné, plynulé utlumování síly
		shake_intensity = lerpf(shake_intensity, 0.0, shake_decay * delta)
		
		# Náhodný posun kamery do všech směrů
		offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_intensity
	else:
		# Nulování pozice, když je klid
		offset = Vector2.ZERO
