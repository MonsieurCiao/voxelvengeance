extends Node
@onready var animation_player: AnimationPlayer = $pistol/AnimationPlayer
@onready var sparks: GPUParticles3D = $sparks


var isShooting = false
var shootCooldown = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") && isShooting == false:
		isShooting = true
		animation_player.play("shoot")
		_shootParticles()
		await get_tree().create_timer(0.4).timeout
		isShooting = false

func _shootParticles() -> void:
	#restartAnimations
	sparks.restart()
	
	#emitting
	sparks.emitting = true
	
	#wait
	await get_tree().create_timer(0.7).timeout
	
	#stopEmitting
	sparks.emitting = false
