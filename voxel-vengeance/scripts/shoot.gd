extends Node3D
@onready var animation_player: AnimationPlayer = $pistol/AnimationPlayer
@onready var sparks: GPUParticles3D = $sparks


var isShooting = false
@export var shootCooldown: float
@onready var camera: Camera3D = $"../../CameraController/Camera3D"

#bullets
var bullet = load("res://scenes/weapons/pistolBullet.tscn")
var bulletInstance
@onready var gun_barrel = $pistol/RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	#actual SHOOTING
	if event.is_action_pressed("shoot") && isShooting == false:
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

<<<<<<< Updated upstream
		await get_tree().create_timer(shootCooldown).timeout
		isShooting = false
=======

func bulletShoot():
	print(weapon_spawner.shootCooldown)
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
>>>>>>> Stashed changes

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
