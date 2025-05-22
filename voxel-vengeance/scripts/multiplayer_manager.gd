extends Node3D

const PLAYER = preload("res://scenes/player.tscn")
var network = ENetMultiplayerPeer.new()
const adress = "zocki.servebeer.com"
const port = 1811

#<Connect
func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connectionfailed)
	
	network.create_client(adress, port)
	network.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = network

func connected_to_server():
	print("Connected to Server")
	MultiplayerManager.rpc_id(1, "receive_input", "input_state")
func connectionfailed():
	print("Connection failed")
#>
@rpc("authority")
func init_player(pos):
	var playerInst = PLAYER.instantiate()
	playerInst.position = pos
	playerInst.name = str(multiplayer.get_unique_id())
	add_child(playerInst)
	$"../main/CameraController".player = get_node("/root/MultiplayerManager/" + str(multiplayer.get_unique_id()))

@rpc("any_peer", "call_local")
func receive_input(input):
	print(input)
