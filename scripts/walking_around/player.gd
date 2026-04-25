extends CharacterBody2D

@export var speed: float = 200.0
@export var step_frequency: float = 15.0 # Jak rychle "dupe"
@export var squash_amount: float = 0.15   # Jak moc se sploští (0.1 = 10%)

@export_group("Textures")
@export var tex_stand_forward: Texture2D
@export var tex_walk_f1: Texture2D
@export var tex_walk_f2: Texture2D
@export var tex_stand_back: Texture2D
@export var tex_walk_b1: Texture2D
@export var tex_walk_b2: Texture2D

@onready var sprite = $Sprite2D # Ujisti se, že se tvůj Sprite jmenuje přesně takto

var time: float = 0.0

var original_scale_x  : float = 0
var original_scale_y  : float =0

func _ready() -> void:
	original_scale_x   = sprite.scale.x
	original_scale_y   = sprite.scale.y

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		time += delta * step_frequency
		
		var is_moving_up = direction.y < 0
		
		# Rozhodneme, který frame chůze použít na základě sinu (střídání nohou)
		var walk_frame = 1 if sin(time) > 0 else 2
		
		if is_moving_up:
			sprite.texture = tex_walk_b1 if walk_frame == 1 else tex_walk_b2
		else:
			sprite.texture = tex_walk_f1 if walk_frame == 1 else tex_walk_f2
			
		# Otočení spritu doleva/doprava (mirroring)
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

		# --- TVŮJ SQUASH A STRETCH ---
		var squash_factor = abs(sin(time))
		sprite.scale.y = original_scale_y - (squash_factor * (squash_amount * original_scale_y))
		sprite.scale.x = original_scale_x + (squash_factor * (squash_amount * 0.5 * original_scale_x))
		sprite.position.y = -(squash_factor * 5.0) 
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
		# --- IDLE STAV (Stání) ---
		# Podle toho, kam se díval naposled (můžeme sledovat y velocity)
		if velocity.y < -0.1:
			sprite.texture = tex_stand_back
		else:
			sprite.texture = tex_stand_forward
			
		time = 0.0
		sprite.scale = sprite.scale.move_toward(Vector2(original_scale_x, original_scale_y), delta * 5.0)
		sprite.position.y = move_toward(sprite.position.y, 0, delta * 50.0)

	move_and_slide()
