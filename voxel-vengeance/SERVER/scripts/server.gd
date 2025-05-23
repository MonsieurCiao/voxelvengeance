extends Node3D

const adress = "zocki.servebeer.com"
const port = 1811
const SPEED = 5.0

var network = ENetMultiplayerPeer.new()
var playerlist = {}
var movedir = {}

#weapons
@export var pistol: PackedScene
@export var ak47: PackedScene

@onready var playerScene = preload("res://SERVER/assets/serverPlayer.tscn")

func _ready() -> void:
	network.peer_connected.connect(client_connected)
	network.peer_disconnected.connect(client_disconnected)
	
	network.create_server(port, 8)
	network.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = network
	print("Server ready, waiting for players..")

func client_connected(id):
	print("Player with ID " + str(id) + " connected.")
	playerlist[id] = {"name":"Client"}
	print(playerlist)
	await get_tree().process_frame
	spawnPlayer(id)
	
func client_disconnected(id):
	print("Player with ID " + str(id) + " disconnected.")
	playerlist.erase(id)
	print(playerlist)

func spawnPlayer(id):
	var playerInst = playerScene.instantiate()
	playerInst.name = str(id)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	playerInst.position = Vector3(
		rng.randf_range(-10.0, 10.0),
		2,
		rng.randf_range(-10.0, 10.0)
	)
	$players.add_child(playerInst)
	MultiplayerManager.rpc_id(id, "init_player")
	
func _physics_process(delta: float) -> void:
	if MultiplayerManager.playerKeysDir == {}:
		return
	for id in MultiplayerManager.playerKeysDir:
		if !playerlist.has(id):
			MultiplayerManager.playerKeysDir.erase(id)
			MultiplayerManager.deletePlayerBody.rpc(id)
			#delete local too
			$players.get_node(str(id)).queue_free()
			return
			
		var serverPlayer = $players.get_node(str(id))
		var inputVect = MultiplayerManager.playerKeysDir[id]["move"]
		var weaponSelect = MultiplayerManager.playerKeysDir[id]["weapons"]
		var target_rot = MultiplayerManager.playerKeysDir[id]["targetRot"]
		var newPlayerData = {}
		serverPlayer.rotation.y = lerp_angle(serverPlayer.rotation.y, target_rot, delta * 40) # lerp angle to prevent "jumps"
		
		if weaponSelect.one:
			newPlayerData["weapon"] = "pistol"
		
		#GRAVITY
		if not serverPlayer.is_on_floor():
			serverPlayer.velocity += serverPlayer.get_gravity() * delta
		else:
			serverPlayer.velocity.y = 0.0
		
		# Determine movement direction from camera
		var player_basis = serverPlayer.global_transform.basis
		var forward = player_basis.z.normalized()
		var right = player_basis.x.normalized()
		var move_dir := Vector3.ZERO
		
		if inputVect != Vector2.ZERO:
			move_dir = (right * inputVect.x + forward * inputVect.y).normalized()
			serverPlayer.velocity.x = move_dir.x * SPEED
			serverPlayer.velocity.z = move_dir.z * SPEED
		else:
			serverPlayer.velocity.x = move_toward(serverPlayer.velocity.x,0, SPEED)
			serverPlayer.velocity.z = move_toward(serverPlayer.velocity.z,0, SPEED)
			
		if serverPlayer is CharacterBody3D:
			serverPlayer.move_and_slide()
		newPlayerData["position"] = serverPlayer.position
		newPlayerData["rotation"] = serverPlayer.rotation.y
		newPlayerData["id"] = id
		MultiplayerManager.rpc("send_transform", newPlayerData)


func summonWeaponWithProperties(weaponName, id):
		#Main.currentWeapon = weaponName
		print(weaponName)
		var player = $players.get_node(str(id))
		clear_all_children(player.get_node("weaponSpawner"))
		
		var instance = get(weaponName).instantiate()
		instance.set_multiplayer_authority(id)
		player.get_node("weaponSpawner").add_child(instance)
		
func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.free()
