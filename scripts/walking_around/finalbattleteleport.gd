extends Area2D

@export var target: Node2D
@export var player_path: NodePath
@export var camera_path: NodePath

@export var finalBattle : Node2D

var player
var camera

func _ready():
	player = get_node(player_path)
	camera = get_node_or_null(camera_path)
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body != player:
		return
	
	# 🔥 vypni smoothing
	if camera and camera.has_method("set_position_smoothing_enabled"):
		camera.position_smoothing_enabled = false
	
	# teleport
	player.global_position = target.global_position
	finalBattle.start_end_dream()
	# 💡 počkej frame (aby kamera stihla skočit)
	await get_tree().process_frame
	
	# 🔥 zapni smoothing zpátky
	if camera:
		camera.position_smoothing_enabled = true
