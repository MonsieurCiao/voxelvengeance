extends Node3D

const PLAYER = preload("res://scenes/player.tscn")
var peer = ENetMultiplayerPeer.new()
var authorityID

var playerlist = {}

func _ready():
	#function called to server, not to the other clients (not sure if this is supposed to be here)
	multiplayer.connected_to_server.connect(connected_to_server)	
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.peer_connected.connect(peer_connected)
	
	if "--server" in OS.get_cmdline_args():
		peer.create_server(1811)
		multiplayer.multiplayer_peer = peer
		#function called to all other clients
		multiplayer.peer_connected.connect(
			func(peerID):
				#client
				if multiplayer.is_server():
					print("PeerID " + str(peerID) + " joined.")
					add_player(str(peerID))
		)
		
		#disconnection
		multiplayer.peer_disconnected.connect(remove_player)

func host() -> void:
	peer.create_server(1811)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	#function called to all other clients
	multiplayer.peer_connected.connect(
		func(peerID):
			#client
			print("A Player for " + str(peerID) + " was succesfully created.")
			add_player(str(peerID))
	)
	#host
	update_playerlist.rpc(multiplayer.get_unique_id(), get_node("/root/main/CanvasLayer/PauseMenu/PanelContainer/VBoxContainer/name").text)
	add_player(str(multiplayer.get_unique_id()))
	
	#disconnection
	multiplayer.peer_disconnected.connect(remove_player)
	

func join() -> void:
	peer.create_client("localhost", 1811) # ADDRESS
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
@rpc("any_peer", "call_local")
func update_playerlist(name, id):
	if !playerlist.has(id):
		playerlist[id] = {
			"name": name,
			"id": id
		}
	print(playerlist)

func add_player(nodeName):
	#prevent duplicate players
	if has_node(nodeName):
		print("Player ",nodeName," already exists.")
		return
	var playerinstance = PLAYER.instantiate()
	playerinstance.name = nodeName
	#playerinstance.set_multiplayer_authority(int(nodeName))
	add_child(playerinstance)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func connected_to_server():
	print("Succesfully connected to Server.")
	update_playerlist.rpc(multiplayer.get_unique_id(), get_node("/root/main/CanvasLayer/PauseMenu/PanelContainer/VBoxContainer/name").text)
func connection_failed():
	print("You can't connect to this Server.")
func peer_disconnected(id):
	print("Player with ID " + str(id) + "disconnected from the game.")
func peer_connected(id):
	print("Player with ID " + str(id) + " joined the game.")
