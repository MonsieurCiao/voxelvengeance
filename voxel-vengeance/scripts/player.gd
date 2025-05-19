extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var dash_speed := 10.0
@export var dash_duration := 0.2
@export var dash_cooldownTime := 3.0
var dash_direction := Vector3.ZERO
var dash_timer := 0.0
var dash_cooldown := 0.0
var input_enabled := true
@onready var camera_pivot = get_node("/root/main/CameraController/")
@onready var crosshair = get_node("/root/main/crosshair/")
@onready var crosshair_3d = get_node("/root/main/Crosshair3d/")
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	MultiplayerManager.authorityID = int(str(name))

func _ready() -> void:
	crosshair.hide()
	crosshair_3d.hide()
	position = Vector3(RandomNumberGenerator.new().randf_range(-2, 16),0,0)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not input_enabled:
			return
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# rotate character
		var target_rot = camera_pivot.global_rotation.y
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 20) # lerp angle to prevent "jumps"
		
		
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var dash_velocity := Vector3.ZERO

		# Determine movement direction from camera
		var cam_basis = camera_pivot.global_transform.basis
		var forward = cam_basis.z.normalized()
		var right = cam_basis.x.normalized()
		var move_dir := Vector3.ZERO

		if input_dir != Vector2.ZERO:
			move_dir = (right * input_dir.x + forward * input_dir.y).normalized()

		# DASH INPUT
		if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
			if move_dir != Vector3.ZERO:
				dash_direction = move_dir
			else:
				dash_direction = - global_transform.basis.z.normalized() # dash forward if no input
			dash_timer = dash_duration
			dash_cooldown = dash_cooldownTime

		# APPLY DASH
		if dash_timer > 0.0:
			dash_velocity = dash_direction * dash_speed
			dash_timer -= delta
		else:
			dash_velocity = Vector3.ZERO
			if dash_cooldown > 0.0:
				dash_cooldown -= delta

		# APPLY MOVEMENT
		if move_dir != Vector3.ZERO:
			velocity.x = move_dir.x * SPEED + dash_velocity.x
			velocity.z = move_dir.z * SPEED + dash_velocity.z
		else:
			velocity.x = move_toward(velocity.x, dash_velocity.x, SPEED)
			velocity.z = move_toward(velocity.z, dash_velocity.z, SPEED)

		move_and_slide()
