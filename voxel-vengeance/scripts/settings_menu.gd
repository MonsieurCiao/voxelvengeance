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


func _on_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_full_screen_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		#minimized
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	pass # Replace with function body.
