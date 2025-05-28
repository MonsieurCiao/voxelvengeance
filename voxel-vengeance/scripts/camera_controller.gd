extends Node3D

var sensitivity := 1
var player: Node3D
var current_offset := Vector3.ZERO
var current_rot_x := 0.0
var cam_rotation_y := 0.0

var aim_offset := Vector3(1, -5, -5)
var default_offset := Vector3(0, 0, 0)
var aim_rot_x := deg_to_rad(20)
var default_rot_x := deg_to_rad(0)

var rng := RandomNumberGenerator.new()
var shake_strength := 0.0
var shakeFade := 0.0

@onready var camera = $Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rng.randomize()

func _process(delta: float) -> void:
	if not player:
		if MultiplayerManager.authorityID:
			player = get_node("/root/main/players/" + str(MultiplayerManager.authorityID))
		return

	var aiming = Input.is_action_pressed("aim") and Main.currentWeapon == "sniper"

	var target_offset := aim_offset if aiming else default_offset
	var target_rot_x := aim_rot_x if aiming else default_rot_x

	current_offset = current_offset.lerp(target_offset, delta * 10)
	current_rot_x = lerp(current_rot_x, target_rot_x, delta * 10)

	var rotated_offset = Transform3D(Basis(Vector3.UP, cam_rotation_y)).basis * current_offset
	global_position = player.global_position + rotated_offset

	rotation = Vector3(current_rot_x, cam_rotation_y, 0)
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		camera.h_offset = rng.randf_range(-shake_strength, shake_strength)
		camera.v_offset = rng.randf_range(-shake_strength, shake_strength)
	else:
		camera.h_offset = 0
		camera.v_offset = 0

func _input(event: InputEvent) -> void:
	if player and player.input_enabled and event is InputEventMouseMotion:
		cam_rotation_y -= event.relative.x / 1000 * sensitivity

func shakeCamera(strength: float, fade: float) -> void:
	shake_strength = strength
	shakeFade = fade
