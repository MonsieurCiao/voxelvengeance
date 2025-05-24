class_name PlayerInput extends Node

@export var inputVect := Vector2.ZERO
@export var targetRot := 0.0
var camera_pivot

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	if not is_multiplayer_authority():# or get_multiplayer_authority() != 1:
		return
	camera_pivot = get_node("/root/main/CameraController/")
	
	inputVect = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
	)
	
	targetRot = camera_pivot.global_rotation.y

	# Now the properties exist and can be synchronized if needed
	MultiplayerManager.rpc_id(1, "receive_input", multiplayer.get_unique_id(), inputVect, targetRot)
