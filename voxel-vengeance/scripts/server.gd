extends Node3D

const adress = "zocki.servebeer.com"
const port = 1811
const SPEED = 5.0

var network = ENetMultiplayerPeer.new()
var playerlist = {}
var movedir = {}

@onready var playerScene = preload("res://scenes/player.tscn")

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
	if MultiplayerManager.inputDir == {}:
		return
	for id in MultiplayerManager.inputDir:
		print(id)
		var serverPlayer = $players.get_node(str(id))
		var move_dir := Vector3.ZERO
		var inputVect = MultiplayerManager.inputDir[id]["move"]
		
		if not serverPlayer.is_on_floor():
			serverPlayer.velocity += serverPlayer.get_gravity() * delta
		else:
			serverPlayer.velocity.y = 0.0
		
		if inputVect != Vector2.ZERO:
			move_dir = Vector3(inputVect.x, 0, inputVect.y).normalized()
			serverPlayer.velocity.x = move_dir.x * SPEED
			serverPlayer.velocity.z = move_dir.z * SPEED
		else:
			serverPlayer.velocity.x = move_toward(serverPlayer.velocity.x,0, SPEED)
			serverPlayer.velocity.z = move_toward(serverPlayer.velocity.z,0, SPEED)
			
		if serverPlayer is CharacterBody3D:
			serverPlayer.move_and_slide()
		MultiplayerManager.rpc_id(id, "send_position", serverPlayer.position, id)
