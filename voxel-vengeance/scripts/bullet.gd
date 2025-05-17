extends CharacterBody3D

@export var damage = 10.0
@export var speed = 70.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D
var hit := false

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(transform.basis * Vector3(0,0, -speed) * delta)
	if collision and not hit:
		hit = true
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
