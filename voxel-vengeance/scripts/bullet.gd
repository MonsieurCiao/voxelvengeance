extends CharacterBody3D


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var weapon_spawner: Node3D = $"../../PLAYER/weaponSpawner"
var hit := false
var bulletSpeed
var bulletDamage

func _ready() -> void:
	bulletSpeed = weapon_spawner.bulletSpeed
	bulletDamage = weapon_spawner.bulletDamage

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(transform.basis * Vector3(0,0, -bulletSpeed) * delta)
	if collision and not hit:
		hit = true
		print("hit")
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
