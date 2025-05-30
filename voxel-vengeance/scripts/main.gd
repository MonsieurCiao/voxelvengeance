extends Node

var currentWeapon
signal scene_ready()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = DisplayServer.screen_get_size()
