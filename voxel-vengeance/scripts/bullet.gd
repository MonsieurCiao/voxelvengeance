extends CharacterBody3D


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var player_hit: GPUParticles3D = $particles/player_hit
@onready var wall_hit: GPUParticles3D = $particles/wall_hit

#Sound
@onready var hitSound = get_node("/root/main/multiplayerManager/" + str(MultiplayerManager.authorityID) + "/Sounds/hitSound")

var weapon_spawner
var hit := false
var bulletSpeed: float
var bulletDamage: float



func _enter_tree() -> void:
	if not is_multiplayer_authority():
		return
	

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(transform.basis * Vector3(0,0, -bulletSpeed) * delta)
	if collision and not hit:
		var hitPlayer = collision.get_collider()
		if hitPlayer.has_method("takeDamage"):
			hitSound.play()
			hitPlayer.takeDamage.rpc_id(hitPlayer.get_multiplayer_authority(), bulletDamage)
			player_hit.emitting = true
		else:
			wall_hit.emitting = true
		
		hit = true
		mesh.visible = false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
