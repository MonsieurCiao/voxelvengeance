extends Node3D



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
		rpc_id(1, "request_weapon", "pistol")
		print("SWITCHING WEAPONS")
	if Input.is_key_pressed(KEY_2) and Main.currentWeapon != "ak47":
		rpc_id(1, "request_weapon", "ak47")
