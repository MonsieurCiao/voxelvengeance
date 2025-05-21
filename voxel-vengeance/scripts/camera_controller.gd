extends Node3D

var sensitivity := .5
var player

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _process(delta: float) -> void:
	if player:
		global_position = player.global_position
	elif MultiplayerManager.authorityID:
		player = get_node("/root/main/multiplayerManager/" + str(MultiplayerManager.authorityID))

func _input(event: InputEvent) -> void:
	if player:
		if not player.input_enabled:
			return
		if event is InputEventMouseMotion:
			#rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.y -= event.relative.x / 1000 * sensitivity
