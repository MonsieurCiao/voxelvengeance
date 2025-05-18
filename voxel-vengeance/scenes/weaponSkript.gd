extends Node3D

@export var pistol: PackedScene
@export var ak47: PackedScene

var currentWeapon
var shootCooldown
var autofire
var bulletSpeed
var bulletDamage

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_1):
		summonWeaponWithProperties("pistol", 0.3, Vector3(0,0,0), false, 70, 10)
	if Input.is_key_pressed(KEY_2):
		summonWeaponWithProperties("ak47", 0.1, Vector3(0.4,0,0), true, 140, 5)
		

func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func summonWeaponWithProperties(weaponName, cooldown, position, automaticFire, bspeed, damage):
		bulletSpeed = bspeed
		bulletDamage = damage
		currentWeapon = weaponName
		shootCooldown = cooldown
		autofire = automaticFire
		clear_all_children(self)
		var instance = get(weaponName).instantiate()
		instance.transform.origin = position
		add_child(instance)
