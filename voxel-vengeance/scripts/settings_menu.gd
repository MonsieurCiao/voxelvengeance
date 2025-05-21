extends Control
@onready var camera_controller: Node3D = $"../../CameraController"

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()




func _on_back_pressed() -> void:
	print("back pressed")
	$AnimationPlayer.play_backwards("panel")
	$"../PauseMenu".pause()
	await [$AnimationPlayer.animation_finished]
	hide()
	pass # Replace with function body.


func _on_sensitivity_slider_value_changed(value: float) -> void:
	camera_controller.sensitivity = value
	pass # Replace with function body.


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("WeaponSounds"),
		value
	)
