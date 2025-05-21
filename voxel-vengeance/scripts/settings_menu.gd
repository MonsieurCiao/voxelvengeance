extends Control
@onready var camera_controller: Node3D = $"../../CameraController"

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()




func _on_back_pressed() -> void:
	$AnimationPlayer.play_backwards("panel")
	$"../PauseMenu".pause()
	await [$AnimationPlayer.animation_finished]
	hide()
	pass # Replace with function body.


func _on_sensitivity_slider_value_changed(value: float) -> void:
	camera_controller.sensitivity = value
	pass # Replace with function body.
