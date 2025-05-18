extends Node3D

<<<<<<< Updated upstream
@export var sensitivity := .5
@onready var player: CharacterBody3D = $"../PLAYER"
=======
var sensitivity := .5
var player
@onready var multiplayer_manager: Node3D = $"../multiplayerManager"
>>>>>>> Stashed changes

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
<<<<<<< Updated upstream
	global_position = player.global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.y -= event.relative.x / 1000 * sensitivity
=======
	if player:
		global_position = player.global_position
	elif multiplayer_manager.authorityID:
		player = get_node("/root/main/multiplayerManager/" + str(multiplayer_manager.authorityID))
		print(player)

func _input(event: InputEvent) -> void:
	if player:
		if not player.input_enabled:
			return
		if event is InputEventMouseMotion:
			#rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.y -= event.relative.x / 1000 * sensitivity
>>>>>>> Stashed changes
