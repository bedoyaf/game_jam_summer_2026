extends CharacterBody2D

@export var speed: float = 200.0
@export var step_frequency: float = 15.0 # Jak rychle "dupe"
@export var squash_amount: float = 0.15   # Jak moc se sploští (0.1 = 10%)

@onready var sprite = $Sprite2D # Ujisti se, že se tvůj Sprite jmenuje přesně takto

var time: float = 0.0

var original_scale_x  : float = 0
var original_scale_y  : float =0
	

func _ready() -> void:
	original_scale_x   = sprite.scale.x
	original_scale_y   = sprite.scale.y

func _physics_process(delta: float) -> void:
	# 1. Získání směru pohybu (WASD nebo šipky)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		# Pohyb postavy
		velocity = direction * speed
		
		# 2. Efekt "krokování" (squash and stretch)
		time += delta * step_frequency
		var squash_factor = abs(sin(time)) # Vrací hodnotu mezi 0 a 1
		
		# Postavička se lehce sploští dolů a rozšíří do stran
		sprite.scale.y = original_scale_y- (squash_factor * (squash_amount*original_scale_y))
		sprite.scale.x = original_scale_x + (squash_factor * (squash_amount * 0.5*original_scale_x))
		
		# Volitelné: mírné nadskakování (bobbing)
		sprite.position.y = -(squash_factor * 5.0) 
	else:
		# Zastavení a reset spritu do původního stavu
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		time = 0.0
		sprite.scale = sprite.scale.move_toward(Vector2(original_scale_x, original_scale_y), delta * 5.0)
		sprite.position.y = move_toward(sprite.position.y, 0, delta * 50.0)

	move_and_slide()
