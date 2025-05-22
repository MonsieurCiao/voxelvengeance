extends Node3D

var sensitivity := 1
var player
var camLock = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#func _process(delta: float) -> void:
	#if player:
		#global_position = player.global_position
	#elif :
	#	player = get_node("/root/main/multiplayerManager/" + str(MultiplayerManager.authorityID))

func _input(event: InputEvent) -> void:
	if player:
		if not player.input_enabled:
			return
		if event is InputEventMouseMotion:
			#rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.y -= event.relative.x / 1000 * sensitivity
		if Input.is_key_pressed(KEY_F11):
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
