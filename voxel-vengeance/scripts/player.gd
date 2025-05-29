extends CharacterBody3D

const SPEED = 5.0
const max_health := 50.0
var health: float
@export var dash_speed := 10.0
@export var dash_duration := 0.2
@export var dash_cooldownTime := 3.0
var dash_direction := Vector3.ZERO
var dash_timer := 0.0
var dash_cooldown := 0.0
var input_enabled := true
var deadStare
@onready var camera_pivot = get_node("/root/main/CameraController/")
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

#Sounds
@onready var hurtSound = $"Sounds/hurtSound"
@onready var walkSound = $"Sounds/walkSound"

func _enter_tree() -> void:
	randomSpawn()
	set_multiplayer_authority(int(str(name)))
	print("authorityID" + str(name))
	MultiplayerManager.authorityID = int(str(name))
	$weaponSpawner.set_multiplayer_authority(int(str(name)))
	health = max_health
	


func _ready() -> void:
	#set audiolistener
	if is_multiplayer_authority():
		var audio_listener: AudioListener3D = get_node("/root/main/players/" + str(multiplayer.get_unique_id()) + "/AudioListener3D")
		audio_listener.make_current()
		#connect to signal
		#MultiplayerManager.playerAdded.connect(setName)
		#setName()
		
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if deadStare:
			return
		if not input_enabled:
			return
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# rotate character
		var target_rot = camera_pivot.global_rotation.y
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 40) # lerp angle to prevent "jumps"
		
		
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
			if not walkSound.is_playing():
				walkSound.play()
		else:
			velocity.x = move_toward(velocity.x, dash_velocity.x, SPEED)
			velocity.z = move_toward(velocity.z, dash_velocity.z, SPEED)

		move_and_slide()

@rpc("any_peer")
func takeDamage(damage:float):
	get_node("/root/main/CameraController/").shakeCamera(1, 50)
	health -= damage
	get_node("/root/main/CanvasLayer/UI").setHealthbar(health)
	hurtSound.play()
	if health <= 0:
		health = max_health
		deadStare = true
		$AnimationPlayer.play("fall")
		await get_tree().create_timer(3).timeout
		$AnimationPlayer.play("RESET")
		randomSpawn()
		deadStare = false
		
func randomSpawn():
	var spawn_locations_parent = get_node("/root/main/world/spawnLocations")
	var spawn_points := []
	for child in spawn_locations_parent.get_children():
		if child is Node3D:
			spawn_points.append(child)
	
	if spawn_points.size() > 0:
		var random_index = randi() % spawn_points.size()
		global_position = spawn_points[random_index].global_position
	else:
		push_warning("No spawnpoints")
		position = Vector3(0, 1, 0)

@rpc("any_peer", "call_local")
func setName(playerlist: Dictionary):
	await get_tree().process_frame
	print("called SETNAMES from" + str(multiplayer.get_unique_id())+ " with list " + str(MultiplayerManager.playerlist))
	#if MultiplayerManager.playerlist.has(multiplayer.get_unique_id()):
		#get_node("/root/main/players/" + str(multiplayer.get_unique_id())+"/playerName").text = MultiplayerManager.playerlist[multiplayer.get_unique_id()].name
	#else:
		#print("kacke verdammt")
	#set each players name
	for playerID in playerlist:
		print("doing player " + str(playerID))
		var playerData = playerlist[playerID]
		get_node("/root/main/players/" + str(playerID) + "/playerName").text = playerData.name
