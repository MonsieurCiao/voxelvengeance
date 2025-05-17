extends Control

var paused = false

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func resume():
	#capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	paused = false
	$AnimationPlayer.play_backwards("blur")
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.input_enabled = true

func pause():
	#free mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = true
	$AnimationPlayer.play("blur")
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.input_enabled = false
	
func testEsc():
	if Input.is_action_just_pressed("esc") and paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and paused == true:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_leave_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	testEsc()
