extends Control

var paused = false
var inPauseMenu = false
var inGame = true

func _ready() -> void:
	$PanelPlayer.play("RESET")
	$BlurPlayer.play("RESET")
	
	hide()
func resume():
	#capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inGame = true
	paused = false
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.input_enabled = true
		
	$PanelPlayer.play_backwards("panel")
	$BlurPlayer.play_backwards("blur")
	await [ $BlurPlayer.animation_finished, $PanelPlayer.animation_finished ]
	hide()
	
func pause():
	#free mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	inGame = false
	paused = true
	inPauseMenu = true
	show()
	$BlurPlayer.play("blur")
	$PanelPlayer.play("panel")
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		player.input_enabled = false
	
func testEsc():
	if Input.is_action_just_pressed("esc") and paused == false and inGame:
		pause()
	elif Input.is_action_just_pressed("esc") and paused == true and inPauseMenu:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_settings_pressed() -> void:
	inPauseMenu = false
	$PanelPlayer.play_backwards("panel")
	$'../SettingsMenu'.show()
	$"../SettingsMenu/AnimationPlayer".play("panel")

func _on_leave_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	testEsc()
	pass

#Multiplayer
@onready var multiplayer_manager: Node3D = $"../../multiplayerManager"
func host() -> void:
	multiplayer_manager.host()

func join() -> void:
	multiplayer_manager.join()