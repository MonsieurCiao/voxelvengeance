extends Node3D

@onready var animation_player: AnimationPlayer = $weapon/AnimationPlayer
@onready var sparks: GPUParticles3D = $sparks
@onready var camera = get_node("/root/main/CameraController/Camera3D")

# Bullets
var bullet = load("res://scenes/weapons/pistolBullet.tscn")
var bulletInstance
@onready var gun_barrel = $weapon/RayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var weapon_spawner: Node3D = $".."

@onready var crosshair = get_node("/root/main/crosshair")
@onready var crosshair_3d = get_node("/root/main/Crosshair3d")

var isShooting = false

func _ready():
	crosshair.hide()
	crosshair_3d.hide()

func _process(delta: float) -> void:
	shootRay()
	if weapon_spawner.autofire:
		if Input.is_action_pressed("shoot") and not isShooting and player.input_enabled:
			bulletShoot()
	else:
		if Input.is_action_just_pressed("shoot") and not isShooting and player.input_enabled:
			bulletShoot()

func bulletShoot():
	isShooting = false
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
	return not result

func _shootParticles() -> void:
	sparks.restart()
	sparks.emitting = true
	await get_tree().create_timer(0.7).timeout
	sparks.emitting = false

func shootRay(): 
	var rayLength = 10.0
	var space = get_world_3d().direct_space_state
	var from = global_transform.origin 
	var direction = -global_transform.basis.z.normalized()
	var to = from + direction * rayLength

	var forward_query = PhysicsRayQueryParameters3D.create(from, to)
	var forward_result = space.intersect_ray(forward_query)

	if forward_result:
		crosshair.hide()
		crosshair_3d.show()
		crosshair_3d.position = forward_result.position
	else:
		crosshair.show()
		crosshair_3d.hide()
		var down_from = to + Vector3.UP * 1.0
		var down_to = down_from + Vector3.DOWN * rayLength
		var down_query = PhysicsRayQueryParameters3D.create(down_from, down_to)
		var down_result = space.intersect_ray(down_query)
		if down_result:
			crosshair.position = down_result.position + Vector3.UP * 0.01
