extends Node3D

@onready var label_3d: Label3D = $Node3D/Label3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var damageNum: int

func _ready() -> void:
	label_3d.text = str(damageNum)
	animation_player.play("new_animation")
	await get_tree().create_timer(1).timeout
