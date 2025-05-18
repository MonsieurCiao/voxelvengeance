extends Node3D

@export var sensitivity := .5
@onready var player: CharacterBody3D = $"../PLAYER"
var sensitivity := .5
var player
@onready var multiplayer_manager: Node3D = $"../multiplayerManager"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _process(delta: float) -> void:
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