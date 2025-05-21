extends Node3D

@export var pistol: PackedScene
@export var ak47: PackedScene

var shootCooldown
var autofire
var bulletSpeed: float
var bulletDamage: float
@onready var camera = get_node("/root/main/CameraController")
@onready var player = $".."

func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	var camera_yaw = camera.global_rotation.y
	var targetRot = camera.global_rotation.y - player.global_rotation.y 
	rotation = Vector3(0, targetRot, 0)

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_key_pressed(KEY_1) and Main.currentWeapon != "pistol":
		summonWeaponWithProperties.rpc("pistol")
	if Input.is_key_pressed(KEY_2) and Main.currentWeapon != "ak47":
		summonWeaponWithProperties.rpc("ak47")

func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.free()

@rpc("call_local")
func summonWeaponWithProperties(weaponName):
		Main.currentWeapon = weaponName
		clear_all_children(self)
		var instance = get(weaponName).instantiate()
		instance.set_multiplayer_authority(get_multiplayer_authority())
		add_child(instance)
