extends Node3D

@export var sensitivity = .5

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.y -= event.relative.x / 1000 * sensitivity
