extends Node
@onready var animation_player: AnimationPlayer = $pistol/AnimationPlayer
@onready var sparks: GPUParticles3D = $sparks


var isShooting = false
<<<<<<< Updated upstream
var shootCooldown = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start")
=======
@onready var camera = get_node("/root/main/CameraController/Camera3D")

#bullets
var bullet = load("res://scenes/weapons/pistolBullet.tscn")
var bulletInstance
@onready var gun_barrel = $weapon/RayCast3D
@onready var player: CharacterBody3D = $"../.."
@onready var weapon_spawner: Node3D = $".."

@onready var crosshair = get_node("/root/main/crosshair")
@onready var crosshair_3d = get_node("/root/main/Crosshair3d")

func _ready():
	crosshair.hide()
	crosshair_3d.hide()
>>>>>>> Stashed changes

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
