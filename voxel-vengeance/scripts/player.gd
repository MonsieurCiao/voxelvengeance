extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var input_enabled := true

@export var camera_pivot: Node3D
@onready var crosshair: Sprite3D = $"../crosshair"
@onready var crosshair_3d: MeshInstance3D = $"../Crosshair3d"

func _ready() -> void:
	crosshair.hide()
	crosshair_3d.hide()
	


func _physics_process(delta: float) -> void:
	if not input_enabled:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# rotate character
	var target_rot = camera_pivot.global_rotation.y
	rotation.y = lerp_angle(rotation.y, target_rot, delta * 20) # lerp angle to prevent "jumps"
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#align input_dir to camera
	if input_dir != Vector2.ZERO:
		var camBasis = camera_pivot.global_transform.basis;
		
		var forward = camBasis.z.normalized()
		var right = camBasis.x.normalized()
		
		var move_dir = (right* input_dir.x + forward * input_dir.y).normalized()
		
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
