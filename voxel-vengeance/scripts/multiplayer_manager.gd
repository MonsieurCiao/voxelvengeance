extends Node3D

const PLAYER = preload("res://scenes/player.tscn")
var network = ENetMultiplayerPeer.new()
const adress = "localhost"
const port = 1811

var playerKeysDir = {}

#<Connect
func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connectionfailed)
	
	network.create_client(adress, port)
	#network.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = network

func connected_to_server():
	print("Connected to Server")
func connectionfailed():
	print("Connection failed")
#>
@rpc("authority")
func init_player():
	var playerInst = PLAYER.instantiate()
	playerInst.name = str(multiplayer.get_unique_id())
	add_child(playerInst)
	$"../main/CameraController".player = get_node("/root/MultiplayerManager/" + str(multiplayer.get_unique_id()))

@rpc("any_peer", "call_remote", "unreliable")
func receive_input(id, inputVect, targetRot):
	if not playerKeysDir.has(id):
		playerKeysDir[id] = {}

	playerKeysDir[id]["move"] = inputVect
	playerKeysDir[id]["targetRot"] = targetRot

@rpc("any_peer")
func deletePlayerBody(id):
	get_node("/root/MultiplayerManager/" + str(id)).queue_free()

@rpc("any_peer")
func send_transform(newPlayerData):
	var player = get_node_or_null("/root/MultiplayerManager/" + str(newPlayerData["id"]))
	if not player:
		var playerInst = PLAYER.instantiate()
		playerInst.name = str(newPlayerData["id"])
		add_child(playerInst)
		player = playerInst

	if not player.is_multiplayer_authority():
		# Nur Remote-Spieler interpolieren
		player.position = player.position.lerp(newPlayerData["position"], 0.2)
		player.rotation.y = lerp_angle(player.rotation.y, newPlayerData["rotation"], 0.2)

func request_weapon(weaponName: String):
	var sender_id = multiplayer.get_remote_sender_id()
	#print("REQUEST WEAPON")
	#$"/root/server".summonWeaponWithProperties(weaponName, sender_id)
