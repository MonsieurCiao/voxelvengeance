extends Node3D

const adress = "zocki.servebeer.com"
const port = 1811
var network = ENetMultiplayerPeer.new()
var playerlist = {}

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
	add_child(playerInst)
	MultiplayerManager.rpc_id(id, "init_player",Vector3(0,1,0))

@rpc("any_peer", "call_local")
func receive_input(input):
	print(input)
