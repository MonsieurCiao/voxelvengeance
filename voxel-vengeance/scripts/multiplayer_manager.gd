extends Node3D

const PLAYER = preload("res://scenes/player.tscn")

var peer = ENetMultiplayerPeer.new()
var authorityID

func host() -> void:
	peer.create_server(1811)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(
		func(peerID):
			#client
			print("PeerID " + str(peerID) + " joined.")
			add_player(str(peerID))
	)
	#host
	add_player(str(multiplayer.get_unique_id()))

func join() -> void:
	peer.create_client("localhost", 1811)
	multiplayer.multiplayer_peer = peer
	

func add_player(nodeName):
	var playerinstance = PLAYER.instantiate()
	playerinstance.name = nodeName
	add_child(playerinstance)
