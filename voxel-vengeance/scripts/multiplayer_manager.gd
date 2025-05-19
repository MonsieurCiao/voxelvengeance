extends Node3D

const PLAYER = preload("res://scenes/player.tscn")

var peer = ENetMultiplayerPeer.new()
var authorityID

func _ready():
	#function called to server, not to the other clients (not sure if this is supposed to be here)
	multiplayer.connected_to_server.connect(connected_to_server)	
	multiplayer.connection_failed.connect(connection_failed)
	
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
	multiplayer.multiplayer_peer = peer
	#function called to all other clients
	multiplayer.peer_connected.connect(
		func(peerID):
			#client
			print("PeerID " + str(peerID) + " joined.")
			add_player(str(peerID))
	)
	#host
	add_player(str(multiplayer.get_unique_id()))
	
	#disconnection
	multiplayer.peer_disconnected.connect(remove_player)
	

func join() -> void:
	peer.create_client("localhost", 1811) # ADDRESS
	multiplayer.multiplayer_peer = peer
	

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
	pass
func connection_failed():
	pass
