extends CharacterBody3D
var auth = false

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const max_health := 50.0
var health: float
@export var dash_speed := 10.0
@export var dash_duration := 0.2
@export var dash_cooldownTime := 3.0
var dash_direction := Vector3.ZERO
var dash_timer := 0.0
var dash_cooldown := 0.0
var input_enabled := true
var camera_pivot

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var rollback_synchronizer = $RollbackSynchronizer

@export var input: PlayerInput

func _ready() -> void:
	print(input)
	input.set_multiplayer_authority(int(str(name)))
	rollback_synchronizer.process_settings()

func _gather():
	pass

func _rollback_tick(delta, tick, is_fresh):
	if is_multiplayer_authority() and get_multiplayer_authority() != 1:
		if not input_enabled:
			return
		_force_update_is_on_floor()
			
		camera_pivot = get_node("/root/main/CameraController/")
		
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
			
		velocity *= NetworkTime.physics_factor
		move_and_slide()
		velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity
