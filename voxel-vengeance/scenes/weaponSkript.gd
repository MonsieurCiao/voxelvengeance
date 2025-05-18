extends Node3D

@export var pistol: PackedScene
@export var ak47: PackedScene

var currentWeapon
var shootCooldown
var autofire

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_1):
		summonWeaponWithProperties("pistol", 0.3, Vector3(0,0,0), false)
	if Input.is_key_pressed(KEY_2):
		summonWeaponWithProperties("ak47", 0.1, Vector3(0.4,0,0), true)
		

func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func summonWeaponWithProperties(weaponName, cooldown, position, automaticFire):
		currentWeapon = weaponName
		shootCooldown = cooldown
		autofire = automaticFire
		clear_all_children(self)
		var instance = get(weaponName).instantiate()
		instance.transform.origin = position
		add_child(instance)
