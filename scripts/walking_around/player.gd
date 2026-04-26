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

@onready var player_walking: AudioStreamPlayer2D = $PlayerWalking


var last_facing_up: bool = false

var time: float = 0.0

var original_scale_x  : float = 0
var original_scale_y  : float =0

@export_group("Audio Interaction")
@export var stamp_sound: AudioStream
var audio_player: AudioStreamPlayer

func _ready() -> void:
	original_scale_x   = sprite.scale.x
	original_scale_y   = sprite.scale.y
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	GameManager.hand_clicked.connect(_on_hand_clicked)

func _physics_process(delta: float) -> void:
	GameManager.dream_character_position = position
	#print(GameManager.dream_character_position)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		if not player_walking.playing:
			
			player_walking.play()
		velocity = direction * speed
		time += delta * step_frequency
		
		# --- JEDNODUCHÁ LOGIKA SMĚRU ---
		# Priorita Y: Pokud se hýbe nahoru, jsou to záda. Pokud dolů, je to předek.
		if direction.y < 0: # Jde nahoru (W) -> teď nastaveno na Forward
			last_facing_up = false
		elif direction.y > 0: # Jde dolů (S) -> teď nastaveno na Back
			last_facing_up = true
		else:
			# Osa X zůstává tak, jak ti fungovala:
			# Doleva (A) -> Záda, Doprava (D) -> Předek
			if direction.x < 0:
				last_facing_up = true
			elif direction.x > 0:
				last_facing_up = false
			
		var walk_frame = 1 if sin(time) > 0 else 2
		
		# Nastavení textury podle last_facing_up
		if last_facing_up:
			sprite.texture = tex_walk_b1 if walk_frame == 1 else tex_walk_b2
		else:
			sprite.texture = tex_walk_f1 if walk_frame == 1 else tex_walk_f2
			
		sprite.flip_h = false 

		# --- SQUASH AND STRETCH (Tvůj efekt) ---
		var squash_factor = abs(sin(time))
		sprite.scale.y = original_scale_y - (squash_factor * (squash_amount * original_scale_y))
		sprite.scale.x = original_scale_x + (squash_factor * (squash_amount * 0.5 * original_scale_x))
		sprite.position.y = -(squash_factor * 5.0) 
		
	else:
		player_walking.stop()
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
		# IDLE STAV - Používáme správné IDLE textury
		if last_facing_up:
			sprite.texture = tex_stand_back
		else:
			sprite.texture = tex_stand_forward
			
		time = 0.0
		sprite.scale = sprite.scale.move_toward(Vector2(original_scale_x, original_scale_y), delta * 5.0)
		sprite.position.y = move_toward(sprite.position.y, 0, delta * 50.0)

	move_and_slide()

func _on_hand_clicked() -> void:
	if GameManager.current_state == GameManager.GameState.PAPERWORK:
		return
		
	var mouse_pos = get_global_mouse_position()
	
	# Převedeme myš do lokálních souřadnic samotného Spritu
	var local_mouse = sprite.get_global_transform().affine_inverse() * mouse_pos
	
	# Zkontrolujeme, jestli myš kliknula fyzicky do prostoru samotného obrázku!
	if sprite.get_rect().has_point(local_mouse):
		if stamp_sound:
			print("playing")
			audio_player.stream = stamp_sound
			audio_player.play()
			
		# Juiciness bonus: Splácnutí hráče pod razítkem!
		var tween = create_tween()
		sprite.scale = Vector2(original_scale_x * 1.5, original_scale_y * 0.5)
		tween.tween_property(sprite, "scale", Vector2(original_scale_x, original_scale_y), 0.25).set_trans(Tween.TRANS_BOUNCE)
