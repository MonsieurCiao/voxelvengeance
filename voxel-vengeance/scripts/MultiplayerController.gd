extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(PlayerConnected)
	multiplayer.peer_disconnected.connect(PlayerDisconnected)
	multiplayer.connected_to_server.connect(ConnectedToServer)
	multiplayer.connection_failed.connect(ConnectionFailed)
	pass
	
func ConnectedToServer():
	print("Connected To Server")
	#send information to server
	SendPlayerInformation.rpc_id(1, "", multiplayer.get_unique_id())
	pass
func ConnectionFailed():
	print("Couldn't Connect")
	pass
func PlayerConnected(id):
	print("Player Connected" + str(id))

func PlayerDisconnected(id):
	print("Player Disconnected" + str(id))


@rpc("any_peer")
func SendPlayerInformation(name: String, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			#"level": level
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	pass
	
@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide
	pass

func _on_host_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Players...")
	SendPlayerInformation("", multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	pass # Replace with function body.


func _on_start_game_button_down() -> void:
	StartGame.rpc() #rpc_id(1) to make host run this bish
	pass # Replace with function body.
