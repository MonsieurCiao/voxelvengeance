extends Node3D

# Bullets
var bullet = load("res://scenes/weapons/pistolBullet.tscn")
var bulletInstance
@onready var gun_barrel = $weapon/RayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var weapon_spawner: Node3D = $".."
var animation_player

@onready var crosshair_scene = get_node("/root/main/Crosshairs/std_crosshair")
@onready var wallCrosshair = get_node("/root/main/Crosshairs/wallCrosshair/")
var isShooting = false
var crosshair

var shootCooldown: float

func _ready():
	if Main.currentWeapon == "shotgun":
		animation_player = $weapon/AnimationPlayer2
	else:
		animation_player = $weapon/AnimationPlayer
	
	for item in get_node("/root/main/Crosshairs").get_children():
		item.hide()
	if not is_multiplayer_authority():
		return
	crosshair = WeaponData.getWeaponData()["crosshair"]
	position = WeaponData.getWeaponData()["spawnPosition"]

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	shootRay()
	if not isBarrelClear($weapon/weaponEnd, gun_barrel):
		return
	if WeaponData.getWeaponData()["autofire"]:
		if Input.is_action_pressed("shoot") and not isShooting and player.input_enabled:
			bulletShoot.rpc(WeaponData.getWeaponData()["bulletSpeed"],WeaponData.getWeaponData()["damage"], WeaponData.getWeaponData()["cooldown"], multiplayer.get_unique_id(), WeaponData.getWeaponData()["weaponname"])
			get_node("/root/main/CameraController/").shakeCamera(WeaponData.getWeaponData()["shakeStrength"], WeaponData.getWeaponData()["shakeFade"])
	else:
		if Input.is_action_just_pressed("shoot") and not isShooting and player.input_enabled:
			bulletShoot.rpc(WeaponData.getWeaponData()["bulletSpeed"],WeaponData.getWeaponData()["damage"], WeaponData.getWeaponData()["cooldown"], multiplayer.get_unique_id(), WeaponData.getWeaponData()["weaponname"])
			get_node("/root/main/CameraController/").shakeCamera(WeaponData.getWeaponData()["shakeStrength"], WeaponData.getWeaponData()["shakeFade"])

@rpc("call_local")
func bulletShoot(bulletSpeed,damage, cooldown, shooterID, weapon):
	if not isBarrelClear($weapon/weaponEnd, gun_barrel):
		return
	isShooting = true
	
	animation_player.play("shoot")
	_shootParticles()
	bulletInstance = bullet.instantiate()
	bulletInstance.position = gun_barrel.global_position
	bulletInstance.transform.basis = gun_barrel.global_transform.basis
	bulletInstance.bulletSpeed = bulletSpeed
	bulletInstance.bulletDamage = damage
	
	bulletInstance.set_multiplayer_authority(get_multiplayer_authority())
	var bullet_container = get_tree().get_current_scene().get_node("Bullets")
	bullet_container.add_child(bulletInstance)
	
	var sounddir = get_node("/root/main/players/" + str(shooterID) + "/weaponSpawner/" + weapon + "/sounds/AudioStreamPlayer3D")
	#var rnd = RandomNumberGenerator.new()
	#rnd.randomize()
	#sounddir.get_children()[rnd.randi_range(0, sounddir.get_child_count() - 1)].play()
	sounddir.play()
	
	if is_multiplayer_authority():
		crosshair_scene.makeCrosshairBigger(WeaponData.getWeaponData()["shrinkSpeed"], WeaponData.getWeaponData()["growSpeed"], WeaponData.getWeaponData()["maxSpread"])
	
	await get_tree().create_timer(cooldown).timeout
	isShooting = false

func isBarrelClear(weaponend, gun_barrel: Node3D) -> bool:
	var from = weaponend.global_transform.origin
	var to = gun_barrel.global_transform.origin
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return not result

func _shootParticles() -> void:
	#get_node("particles/sparks").emitting = true
	for item in $particles.get_children():
		item.restart()
		item.emitting = true
	await get_tree().create_timer(WeaponData.getWeaponData()["cooldown"]).timeout
	for item in $particles.get_children():
		item.emitting = false

func shootRay():
	var space = get_world_3d().direct_space_state
	var from = global_transform.origin
	var direction = - global_transform.basis.z.normalized()
	var to = from + direction * WeaponData.getWeaponData()["rayLength"]

	var forward_query = PhysicsRayQueryParameters3D.create(from, to)
	var forward_result = space.intersect_ray(forward_query)

	if forward_result:
		crosshair.hide()
		wallCrosshair.show()
		wallCrosshair.position = forward_result.position
	else:
		crosshair.show()
		wallCrosshair.hide()
		var down_from = to + Vector3.UP * 1.0
		var down_to = down_from + Vector3.DOWN * WeaponData.getWeaponData()["rayLength"]
		var down_query = PhysicsRayQueryParameters3D.create(down_from, down_to)
		down_query.collision_mask = 0xFFFFFFFF & ~(1 << 1)
		var down_result = space.intersect_ray(down_query)
		if down_result:
			crosshair.position = down_result.position + Vector3.UP * 0.01
		crosshair.rotation = player.rotation
