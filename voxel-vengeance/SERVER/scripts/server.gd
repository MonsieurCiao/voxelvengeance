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

@onready var playerScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	network.peer_connected.connect(client_connected)
	network.peer_disconnected.connect(client_disconnected)
	
	network.create_server(port, 8)
	#network.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
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
	var randoms = int(RandomNumberGenerator.new().randf_range(0, $world.get_node("spawnPoints").get_child_count()-1))
	playerInst.name = str(id)
	playerInst.position = $world.get_node("spawnPoints").get_children()[randoms].position
	get_node("/root/MultiplayerManager/").add_child(playerInst)
	MultiplayerManager.rpc_id(id, "init_player")

func _physics_process(delta: float) -> void:
	for id in MultiplayerManager.playerKeysDir:
		if not playerlist.has(id):
			continue

		var player_node = get_node("/root/MultiplayerManager/").get_node(str(id))
		var input = MultiplayerManager.playerKeysDir[id]
		if not input:
			continue

		var move_input = input.get("move", Vector2.ZERO)
		var dash_input = input.get("dash", false)
		var target_rot = input.get("targetRot", 0.0)
		# Rotation
		player_node.rotation.y = lerp_angle(player_node.rotation.y, target_rot, delta * 20)

		# Gravity
		if not player_node.is_on_floor():
			player_node.velocity += player_node.get_gravity() * delta
		else:
			player_node.velocity.y = 0.0

		# Bewegung
		var basis = player_node.global_transform.basis
		var forward = basis.z.normalized()
		var right = basis.x.normalized()
		var move_dir = (right * move_input.x + forward * move_input.y).normalized()
		if move_dir != Vector3.ZERO:
			player_node.velocity.x = move_dir.x * SPEED
			player_node.velocity.z = move_dir.z * SPEED
		else:
			player_node.velocity.x = move_toward(player_node.velocity.x, 0, SPEED)
			player_node.velocity.z = move_toward(player_node.velocity.z, 0, SPEED)

		player_node.move_and_slide()
		print(player_node.position)
		
		MultiplayerManager.rpc("send_transform", {
			"id": id,
			"position": player_node.position,
			"rotation": player_node.rotation.y
		})


func summonWeaponWithProperties(weaponName, id):
		#Main.currentWeapon = weaponName
		print(weaponName)
		var player = get_node("/root/MultiplayerManager/").get_node(str(id))
		clear_all_children(player.get_node("weaponSpawner"))
		
		var instance = get(weaponName).instantiate()
		instance.set_multiplayer_authority(id)
		player.get_node("weaponSpawner").add_child(instance)
		
func clear_all_children(node: Node) -> void:
	for child in node.get_children():
		child.free()
