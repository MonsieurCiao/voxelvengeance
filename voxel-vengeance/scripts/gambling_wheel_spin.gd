extends Node3D
@onready var animation_player: AnimationPlayer = $Cylinder/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animation_player.play("spin")
	get_tree().create_timer(animation_player.current_animation_length).timeout
