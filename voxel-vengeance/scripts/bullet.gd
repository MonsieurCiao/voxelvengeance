extends CharacterBody3D


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var player_hit: GPUParticles3D = $particles/player_hit
@onready var wall_hit: GPUParticles3D = $particles/wall_hit
@onready var case: GPUParticles3D = $particles/case

const DAMAGE_NUMBERS = preload("res://scenes/damageNumbers.tscn")

var weapon_spawner
var hit := false
var bulletSpeed: float
var bulletDamage: int

var animationTime



func _enter_tree() -> void:
	if not is_multiplayer_authority():
		return
		
func _ready() -> void:
	case.emitting = true
	animationTime = case.lifetime
	rotation = Vector3(rotation.x,rotation.y, 0)
	

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(transform.basis * Vector3(0,0, -bulletSpeed) * delta)
	if collision and not hit:
		var hitPlayer = collision.get_collider()
		if hitPlayer.has_method("takeDamage"):
			hitPlayer.takeDamage.rpc_id(hitPlayer.get_multiplayer_authority(), bulletDamage)
			player_hit.emitting = true
			var damageNumbersInst = DAMAGE_NUMBERS.instantiate()
			damageNumbersInst.damageNum = bulletDamage
			add_child(damageNumbersInst)
		else:
			wall_hit.emitting = true
		
		hit = true
		mesh.visible = false
		await get_tree().create_timer(animationTime).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
