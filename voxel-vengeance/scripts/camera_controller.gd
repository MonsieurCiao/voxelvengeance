extends Node3D

@export var sensitivity := .5
@onready var player: CharacterBody3D = $"../PLAYER"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	global_position = player.global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.y -= event.relative.x / 1000 * sensitivity
