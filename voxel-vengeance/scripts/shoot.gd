extends Node3D
@onready var animation_player: AnimationPlayer = $weapon/AnimationPlayer
@onready var sparks: GPUParticles3D = $sparks


var isShooting = false
@onready var camera: Camera3D = $"../../../CameraController/Camera3D"

#bullets
var bullet = load("res://scenes/weapons/pistolBullet.tscn")
var bulletInstance
@onready var gun_barrel = $weapon/RayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var weapon_spawner: Node3D = $".."

@onready var crosshair: Sprite3D = $"../../../crosshair"
@onready var crosshair_3d: MeshInstance3D = $"../../../Crosshair3d"

func _ready() -> void:
	crosshair.hide()
	crosshair_3d.hide()

func _process(delta: float) -> void:
	shootRay()
	if weapon_spawner.autofire:
		if Input.is_action_pressed("shoot") && isShooting == false && player.input_enabled == true:
			bulletShoot()
	else:
		if Input.is_action_just_pressed("shoot") && isShooting == false && player.input_enabled == true:
			bulletShoot()

func bulletShoot():
	isShooting = false
	# check if is in wall
	if not isBarrelClear(camera, gun_barrel):
		return
	isShooting = true
	animation_player.play("shoot")
	_shootParticles()
	bulletInstance = bullet.instantiate()
	bulletInstance.position = gun_barrel.global_position
	bulletInstance.transform.basis = gun_barrel.global_transform.basis
	var bullet_container = get_tree().get_current_scene().get_node("Bullets")
	bullet_container.add_child(bulletInstance)
	await get_tree().create_timer(weapon_spawner.shootCooldown).timeout
	isShooting = false

func isBarrelClear(camera: Node3D, gun_barrel: Node3D) -> bool:
	var from = camera.global_transform.origin
	var to = gun_barrel.global_transform.origin
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		return false
	else:
		return true
	

func _shootParticles() -> void:
	#restartAnimations
	sparks.restart()
	
	#emitting
	sparks.emitting = true
	
	#wait
	await get_tree().create_timer(0.7).timeout
	
	#stopEmitting
	sparks.emitting = false

func shootRay(): 
	var rayLength = 10.0
	var space = get_world_3d().direct_space_state

	# Step 1: Cast a ray forward from the player
	var from = global_transform.origin 
	var direction = -global_transform.basis.z.normalized()
	var to = from + direction * rayLength

	var forward_query = PhysicsRayQueryParameters3D.create(from, to)
	var forward_result = space.intersect_ray(forward_query)

	if forward_result:
		crosshair.hide()
		crosshair_3d.show()
		crosshair_3d.position = forward_result.position
		# switch crosshair
		
	else:
		crosshair.show()
		crosshair_3d.hide()
		# cast a ray downward from the end point
		var down_from = to + Vector3.UP * 1.0
		var down_to = down_from + Vector3.DOWN * rayLength
		var down_query = PhysicsRayQueryParameters3D.create(down_from, down_to)
		var down_result = space.intersect_ray(down_query)

		if down_result:
			crosshair.position = down_result.position + Vector3.UP * 0.01
