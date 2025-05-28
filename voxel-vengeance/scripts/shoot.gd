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
	crosshair = WeaponData.getWeaponData(Main.currentWeapon)["crosshair"]


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	shootRay()
	if not isBarrelClear($weapon/weaponEnd, gun_barrel):
		return
	if WeaponData.getWeaponData(Main.currentWeapon)["autofire"]:
		if Input.is_action_pressed("shoot") and not isShooting and player.input_enabled:
			isShooting = true
			bulletShoot.rpc(
				WeaponData.getWeaponData(Main.currentWeapon)["bulletSpeed"],
				WeaponData.getWeaponData(Main.currentWeapon)["damage"],
				WeaponData.getWeaponData(Main.currentWeapon)["cooldown"],
				multiplayer.get_unique_id(),
				WeaponData.getWeaponData(Main.currentWeapon)["weaponname"],
				WeaponData.getWeaponData(Main.currentWeapon)["bulletNum"],
				WeaponData.getWeaponData(Main.currentWeapon)["angle"])
			get_node("/root/main/CameraController/").shakeCamera(
				WeaponData.getWeaponData(Main.currentWeapon)["shakeStrength"],
				WeaponData.getWeaponData(Main.currentWeapon)["shakeFade"]
				)
			await get_tree().create_timer(WeaponData.getWeaponData(Main.currentWeapon)["cooldown"]).timeout
			isShooting = false
	else:
		if Input.is_action_just_pressed("shoot") and not isShooting and player.input_enabled:
			isShooting = true
			bulletShoot.rpc(
				WeaponData.getWeaponData(Main.currentWeapon)["bulletSpeed"],
				WeaponData.getWeaponData(Main.currentWeapon)["damage"],
				WeaponData.getWeaponData(Main.currentWeapon)["cooldown"],
				multiplayer.get_unique_id(),
				WeaponData.getWeaponData(Main.currentWeapon)["weaponname"],
				WeaponData.getWeaponData(Main.currentWeapon)["bulletNum"],
				WeaponData.getWeaponData(Main.currentWeapon)["angle"])
			get_node("/root/main/CameraController/").shakeCamera(
				WeaponData.getWeaponData(Main.currentWeapon)["shakeStrength"],
				WeaponData.getWeaponData(Main.currentWeapon)["shakeFade"]
				)
			await get_tree().create_timer(WeaponData.getWeaponData(Main.currentWeapon)["cooldown"]).timeout
			isShooting = false
				
@rpc("call_local")
func bulletShoot(bulletSpeed,damage, cooldown, shooterID, weapon, num, maxangle):
	if not isBarrelClear($weapon/weaponEnd, gun_barrel):
		return
	var targetAngles = generate_angle_array(num, maxangle)
		
	for angle in targetAngles:
		bulletInstance = bullet.instantiate()
		bulletInstance.position = gun_barrel.global_position
		bulletInstance.transform.basis = gun_barrel.global_transform.basis
		bulletInstance.bulletSpeed = bulletSpeed
		bulletInstance.bulletDamage = damage
		bulletInstance.shooter = shooterID
		bulletInstance.shootAngle = angle
		
		bulletInstance.set_multiplayer_authority(get_multiplayer_authority())
		var bullet_container = get_tree().get_current_scene().get_node("Bullets")
		bullet_container.add_child(bulletInstance)
	
	if animation_player:
		animation_player.play("shoot")
	_shootParticles(weapon)
	var audio = get_node_or_null("/root/main/players/" + str(shooterID) + "/weaponSpawner/" + weapon + "/sounds/AudioStreamPlayer3D")
	if audio:
		audio.play()
	
	if is_multiplayer_authority():
		crosshair_scene.makeCrosshairBigger(WeaponData.getWeaponData(weapon)["shrinkSpeed"], WeaponData.getWeaponData(weapon)["growSpeed"], WeaponData.getWeaponData(weapon)["maxSpread"])
	
	await get_tree().create_timer(cooldown).timeout
	
func generate_angle_array(n: int, max_angle: float) -> Array:
	if n <= 1:
		return [0.0]  # Nur ein Element → Mittelpunkt
	var angles = []
	var start_angle = -max_angle / 2.0
	var step = max_angle / (n - 1)
	for i in range(n):
		angles.append(start_angle + i * step)
	return angles

func isBarrelClear(weaponend, gun_barrel: Node3D) -> bool:
	var from = weaponend.global_transform.origin
	var to = gun_barrel.global_transform.origin
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return not result

func _shootParticles(weaponName) -> void:
	#get_node("particles/sparks").emitting = true
	for item in $particles.get_children():
		item.restart()
		item.emitting = true
	await get_tree().create_timer(WeaponData.getWeaponData(weaponName)["cooldown"]).timeout
	for item in $particles.get_children():
		item.emitting = false

@onready var shape_cast = $ShapeCast3D

func shootRay():
	var space = get_world_3d().direct_space_state
	shape_cast.target_position = Vector3(0, 0, -WeaponData.getWeaponData(Main.currentWeapon)["rayLength"] * 5)

	if shape_cast.is_colliding():
		var collision_point = shape_cast.get_collision_point(0)
		wallCrosshair.show()
		crosshair.hide()

		# wallCrosshair als Weltposition, damit Größe stabil bleibt
		wallCrosshair.global_position = collision_point + Vector3.UP * 0.01

	else:
		wallCrosshair.hide()
		crosshair.show()

		var target_point = shape_cast.global_transform.origin + shape_cast.global_transform.basis * shape_cast.target_position
		var down_from = target_point + Vector3.UP * 1.0
		var down_to = down_from + Vector3.DOWN * 10.0

		var down_query = PhysicsRayQueryParameters3D.create(down_from, down_to)
		down_query.collision_mask = 0xFFFFFFFF & ~(1 << 1)
		var down_result = space.intersect_ray(down_query)

		if down_result:
			crosshair.position = down_result.position + Vector3.UP * 0.01

		crosshair.rotation = player.rotation
