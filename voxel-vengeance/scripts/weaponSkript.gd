extends Node3D

@export var pistol: PackedScene
@export var ak47: PackedScene

var shootCooldown
var autofire
var bulletSpeed: float
var bulletDamage: float

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_key_pressed(KEY_1) and Main.currentWeapon != "pistol":
		summonWeaponWithProperties.rpc("pistol", 0.3, Vector3(0,0,-.2), false, 70, 10)
	if Input.is_key_pressed(KEY_2) and Main.currentWeapon != "ak47":
		summonWeaponWithProperties.rpc("ak47", 0.1, Vector3(0.4,0,0), true, 140, 5)

func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.free()

@rpc("call_local")
func summonWeaponWithProperties(weaponName, cooldown, bposition, automaticFire, bspeed, damage):
		Main.currentWeapon = weaponName
		clear_all_children(self)
		var instance = get(weaponName).instantiate()
		instance.bulletSpeed = bspeed
		instance.autofire = automaticFire
		instance.bulletDamage = damage
		instance.transform.origin = bposition
		instance.shootCooldown = cooldown
		instance.set_multiplayer_authority(get_multiplayer_authority())
		add_child(instance)
