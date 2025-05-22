extends CharacterBody3D
var auth = false

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const max_health := 50.0
var health: float
@export var dash_speed := 10.0
@export var dash_duration := 0.2
@export var dash_cooldownTime := 3.0
@onready var camera_pivot = get_node("/root/main/CameraController/")
var dash_direction := Vector3.ZERO
var dash_timer := 0.0
var dash_cooldown := 0.0
var input_enabled := true

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

#Sounds
@onready var hurtSound = $"Sounds/hurtSound"
@onready var walkSound = $"Sounds/walkSound"

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	$weaponSpawner.set_multiplayer_authority(int(str(name)))
	health = max_health

func _ready() -> void:
	auth = is_multiplayer_authority()
	position = Vector3(-9, 1, -6)
	#set audiolistener
	if is_multiplayer_authority():
		var audio_listener: AudioListener3D = get_node("/root/MultiplayerManager/" + str(multiplayer.get_unique_id()) + "/AudioListener3D")
		audio_listener.make_current()
#		$playerName.text = MultiplayerManager.playerlist[multiplayer.get_unique_id()].name
		var input_state = {"move": Vector2(0,0), "targetRot": 0.0}
		MultiplayerManager.rpc_id(1, "receive_input", input_state)

var last_input_state = {}
func _physics_process(_delta):
	#if is_multiplayer_authority():
		var input_state = {
			"move": Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("backward") - Input.get_action_strength("forward")), 
			"targetRot": camera_pivot.global_rotation.y
			}
		if input_state != last_input_state:
			MultiplayerManager.rpc_id(1, "receive_input", input_state)
			last_input_state = input_state

#func _physics_process(delta: float) -> void:
#	if is_multiplayer_authority():
#		if not input_enabled:
#			return
#		# Add the gravity.
#		if not is_on_floor():
#			velocity += get_gravity() * delta
#		
#		# rotate character
#		var target_rot = camera_pivot.global_rotation.y
#		rotation.y = lerp_angle(rotation.y, target_rot, delta * 40) # lerp angle to prevent "jumps"
#		
#		
#		var input_dir := Input.get_vector("left", "right", "forward", "backward")
#		var dash_velocity := Vector3.ZERO
#
#		# Determine movement direction from camera
#		var cam_basis = camera_pivot.global_transform.basis
#		var forward = cam_basis.z.normalized()
#		var right = cam_basis.x.normalized()
#		var move_dir := Vector3.ZERO
#
#		if input_dir != Vector2.ZERO:
#			move_dir = (right * input_dir.x + forward * input_dir.y).normalized()
#
#		# DASH INPUT
#		if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
#			if move_dir != Vector3.ZERO:
#				dash_direction = move_dir
#			else:
#				dash_direction = - global_transform.basis.z.normalized() # dash forward if no input
#			dash_timer = dash_duration
#			dash_cooldown = dash_cooldownTime
#
#		# APPLY DASH
#		if dash_timer > 0.0:
#			dash_velocity = dash_direction * dash_speed
#			dash_timer -= delta
#		else:
#			dash_velocity = Vector3.ZERO
#			if dash_cooldown > 0.0:
#				dash_cooldown -= delta
#
#		# APPLY MOVEMENT
#		if move_dir != Vector3.ZERO:
#			velocity.x = move_dir.x * SPEED + dash_velocity.x
#			velocity.z = move_dir.z * SPEED + dash_velocity.z
#			if not walkSound.is_playing():
#				walkSound.play()
#		else:
#			velocity.x = move_toward(velocity.x, dash_velocity.x, SPEED)
#			velocity.z = move_toward(velocity.z, dash_velocity.z, SPEED)
#
#		move_and_slide()
#
#@rpc("any_peer")
#func takeDamage(damage:float):
#	health -= damage
#	hurtSound.play()
#	if hurtSound: print("hurt sound")
#	if health <= 0:
#		health = max_health
#		position = Vector3(0, 1, 0)
