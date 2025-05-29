extends CanvasLayer

func _on_host_button_up() -> void:
	var name = $"Menu/MarginContainer/PlayActions/name".text
	MultiplayerManager.receive_name(name)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	MultiplayerManager.host()
	pass # Replace with function body.


func _on_join_pressed() -> void:
	var name = $"Menu/MarginContainer/PlayActions/name".text
	MultiplayerManager.receive_name(name)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	MultiplayerManager.join()
	
	pass # Replace with function body.
