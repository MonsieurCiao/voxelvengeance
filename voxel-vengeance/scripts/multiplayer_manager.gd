extends Node3D

const PLAYER = preload("res://scenes/player.tscn")
var peer = ENetMultiplayerPeer.new()
var authorityID

signal playerAdded
var playerlist = {}
var curName = ""

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

func receive_name(name: String) -> void:
	curName = name

func host() -> void:
	peer.create_server(1811)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	#function called to all other clients
	multiplayer.peer_connected.connect(
		func(peerID):
			#client
			await _wait_for_players_node()
			add_player(str(peerID))
			print(multiplayer.get_unique_id()) # 1
			await get_tree().process_frame
			update_playerlist.rpc_id(peerID, multiplayer.get_unique_id(), curName, MultiplayerManager.playerlist)
	)
	await _wait_for_players_node()
	update_playerlist.rpc(multiplayer.get_unique_id(), curName, playerlist)
	#host
	add_player(str(multiplayer.get_unique_id()))
	
	#disconnection
	multiplayer.peer_disconnected.connect(remove_player)
	

func join() -> void:
	await _wait_for_players_node()
	peer.create_client("zocki.servebeer.com", 1811)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
@rpc("any_peer", "call_local")
func update_playerlist(id, name: String, list: Dictionary):
	#get the player list from host
	print("From " + str(multiplayer.get_unique_id()) + " list " + str(list))
	if !MultiplayerManager.playerlist.has(id):
		print(name)
		MultiplayerManager.playerlist[int(id)] = {
			"name": name,
			"id": int(id)
		}
	print("MultiplayerManager.playerlist", MultiplayerManager.playerlist)
	disperseNames.rpc()
	#make host loop over each peer and call their setName with host's playerlist
		#if player_node and player_node.has_method("setName"):
			#player_node.setName()

@rpc("any_peer", "call_local")
func disperseNames():
	print("DISPERSING NAMES")
	await get_tree().process_frame
	if multiplayer.get_unique_id() == 1:
		for peer_id in MultiplayerManager.playerlist:
			var player_node = get_node_or_null("/root/main/players/" + str(peer_id))
			if player_node:
				player_node.setName.rpc_id(peer_id, MultiplayerManager.playerlist)

func add_player(nodeName):
	#prevent duplicate players
	if has_node(nodeName):
		print("Player ", nodeName, " already exists.")
		return
	var playerinstance = PLAYER.instantiate()
	playerinstance.name = nodeName
	$"../main/players/".add_child(playerinstance)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func connected_to_server():
	print("Succesfully connected to Server.")
	disperseNames.rpc()
func connection_failed():
	print("You can't connect to this Server.")
func peer_disconnected(id):
	print("Player with ID " + str(id) + "disconnected from the game.")
func peer_connected(peerID):
	print("A Player for " + str(peerID) + " was succesfully created.")
	update_playerlist.rpc_id(peerID, multiplayer.get_unique_id(), curName, MultiplayerManager.playerlist)

func _wait_for_players_node():
	while get_node_or_null("/root/main/players") == null:
		await get_tree().process_frame
	return
