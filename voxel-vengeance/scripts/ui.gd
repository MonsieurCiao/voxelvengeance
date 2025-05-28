extends Control
var health := 50.0
var a := 0.0
var player

func setHealthbar(playerHealth):
	health = playerHealth
	a = 1.0

func _process(delta: float) -> void:
	player = get_node_or_null("/root/main/players/" + str(multiplayer.get_unique_id()))
	
	a -= delta
	#if $ProgressBar.value != health:
	$healthbar.value = move_toward($healthbar.value, health, 75 * delta)
	if a <= 0:
		$healthbarRed.value = move_toward($healthbarRed.value, $healthbar.value, 150 * delta)
	
	#DASH
	if $dashBar.value == $dashBar.max_value:
		$dashBar.modulate.a = 1
	else:
		$dashBar.modulate.a = 0.5
	if player:
		$dashBar.value = move_toward($dashBar.value,$dashBar.max_value-player.dash_cooldown, 40*delta)
