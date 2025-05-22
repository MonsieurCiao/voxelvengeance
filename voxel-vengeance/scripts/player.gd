extends CharacterBody3D
var auth = false

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const max_health := 50.0
var health: float
@export var dash_speed := 10.0
@export var dash_duration := 0.2
@export var dash_cooldownTime := 3.0
@onready var camera_pivot = get_node("/root/main/CameraController/")
var dash_direction := Vector3.ZERO
var dash_timer := 0.0
var dash_cooldown := 0.0
var input_enabled := true

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	$weaponSpawner.set_multiplayer_authority(int(str(name)))
	health = max_health

func _ready() -> void:
	auth = is_multiplayer_authority()
	position = Vector3(-9, 1, -6)
	#set audiolistener
	if is_multiplayer_authority():
		var audio_listener: AudioListener3D = get_node("/root/MultiplayerManager/" + str(multiplayer.get_unique_id()) + "/AudioListener3D")
		audio_listener.make_current()
#		$playerName.text = MultiplayerManager.playerlist[multiplayer.get_unique_id()].name

var last_input_state = {}
func _physics_process(_delta):
	#if is_multiplayer_authority():
		var input_state = {
			"move": Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("backward") - Input.get_action_strength("forward")),
			}
		if input_state != last_input_state:
			MultiplayerManager.rpc_id(1, "receive_input", input_state)
			last_input_state = input_state
