extends Node3D

const adress = "zocki.servebeer.com"
const port = 1811
const SPEED = 5.0

var network = ENetMultiplayerPeer.new()
var playerlist = {}
var movedir = {}

#weapons
var weapon_dict = {
		"1": "pistol",
		"2": "ak47",
	}

@onready var playerScene = preload("res://SERVER/assets/serverPlayer.tscn")

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
	var randoms = int(RandomNumberGenerator.new().randf_range(0, $world.get_node("spawnPoints").get_child_count()-1))
	playerInst.name = str(id)
	playerInst.position = $world.get_node("spawnPoints").get_children()[randoms].position
	$players.add_child(playerInst)
	MultiplayerManager.rpc_id(id, "init_player")
	
func _physics_process(delta: float) -> void:
	if MultiplayerManager.playerKeysDir == {}:
		return
	for id in MultiplayerManager.playerKeysDir:
		if !playerlist.has(id):
			MultiplayerManager.playerKeysDir.erase(id)
			MultiplayerManager.deletePlayerBody.rpc(id)
			#delete local too
			$players.get_node(str(id)).queue_free()
			return
			
		var serverPlayer = $players.get_node(str(id))
		var inputVect = MultiplayerManager.playerKeysDir[id]["move"]
		var weaponSelect = MultiplayerManager.playerKeysDir[id]["weapons"]
		var mouseLeft = MultiplayerManager.playerKeysDir[id]["mouse"]["left"]
		var target_rot = MultiplayerManager.playerKeysDir[id]["targetRot"]
		var newPlayerData = {}
		serverPlayer.rotation.y = lerp_angle(serverPlayer.rotation.y, target_rot, delta * 40) # lerp angle to prevent "jumps"
		
		#search weaponSelect (dict) for true
		var weapon:String
		for key in weaponSelect.keys():
			if weaponSelect[key] == true:
				weapon = weapon_dict.get(str(key))
		newPlayerData["weapon"] = weapon
		if weapon != "": summonWeaponWithProperties(weapon, id)
		
		if mouseLeft:
			shootRay()
			shoot()
	
		
		#GRAVITY
		if not serverPlayer.is_on_floor():
			serverPlayer.velocity += serverPlayer.get_gravity() * delta
		else:
			serverPlayer.velocity.y = 0.0
		
		# Determine movement direction from camera
		var player_basis = serverPlayer.global_transform.basis
		var forward = player_basis.z.normalized()
		var right = player_basis.x.normalized()
		var move_dir := Vector3.ZERO
		
		if inputVect != Vector2.ZERO:
			move_dir = (right * inputVect.x + forward * inputVect.y).normalized()
			serverPlayer.velocity.x = move_dir.x * SPEED
			serverPlayer.velocity.z = move_dir.z * SPEED
		else:
			serverPlayer.velocity.x = move_toward(serverPlayer.velocity.x,0, SPEED)
			serverPlayer.velocity.z = move_toward(serverPlayer.velocity.z,0, SPEED)
			
		if serverPlayer is CharacterBody3D:
			serverPlayer.move_and_slide()
		newPlayerData["position"] = serverPlayer.position
		newPlayerData["rotation"] = serverPlayer.rotation.y
		newPlayerData["id"] = id
		MultiplayerManager.rpc("send_transform", newPlayerData)


func summonWeaponWithProperties(weapon: String, id:int):
		MultiplayerManager.rpc("assign_weapon", weapon, id) #save info and client player

func shoot():
	
	MultiplayerManager.rpc("propagate_bullet_data")
	pass
func shootRay():
	var space = get_world_3d().direct_space_state
	var from = global_transform.origin
	var direction = - global_transform.basis.z.normalized()
	var to = from + direction * rayLength

	var forward_query = PhysicsRayQueryParameters3D.create(from, to)
	var forward_result = space.intersect_ray(forward_query)

	if forward_result:
		crosshair.hide()
		wallCrosshair.show()
		wallCrosshair.position = forward_result.position
	else:
		crosshair.show()
		wallCrosshair.hide()
		var down_from = to + Vector3.UP * 1.0
		var down_to = down_from + Vector3.DOWN * rayLength
		var down_query = PhysicsRayQueryParameters3D.create(down_from, down_to)
		down_query.collision_mask = 0xFFFFFFFF & ~(1 << 1)
		var down_result = space.intersect_ray(down_query)
		if down_result:
			crosshair.position = down_result.position + Vector3.UP * 0.01
		crosshair.rotation = player.rotation
