extends Camera3D
#
#@onready var crosshair: Sprite3D = $"../../crosshair"
#@onready var player: CharacterBody3D = $"../../PLAYER"
#
#
#func _process(delta: float) -> void:
	#if not player.input_enabled:
		#return
#
	#var mouse_position = get_viewport().get_mouse_position()
	#var rayLength = 1000
	#var from = project_ray_origin(mouse_position)
	#var to = project_ray_normal(mouse_position) * rayLength
	#var space = get_world_3d().direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(from, to)
	#
	#var result = space.intersect_ray(query)
	#if result:
		#crosshair.position = result["position"] + Vector3.UP
