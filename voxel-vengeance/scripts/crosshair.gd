extends Node3D

#CHATGPT<
var base_distance := 0.2
var current_offset := 0.0
var target_offset := 0.0
var velocity := 0.0

# Tweakbare Parameter
var MAX_SPREAD_PER_SHOT = 0.0
var SMOOTH_SPEED = 0.0
var SHRINK_RATE = 0.0

func _process(delta: float) -> void:
	# Zielposition reduziert sich kontinuierlich = smooth zurückgehen
	target_offset = lerp(target_offset, 0.0, delta * SHRINK_RATE)

	# current_offset bewegt sich smooth in Richtung target_offset
	current_offset = lerp(current_offset, target_offset, delta * SMOOTH_SPEED)

	# Beispiel für 4 Crosshair-Balken
	$Top.position.z = - (base_distance + current_offset)
	$Bottom.position.z = base_distance + current_offset
	$Left.position.x = - (base_distance + current_offset)
	$Right.position.x = base_distance + current_offset

func makeCrosshairBigger(shrinkSpeed, growSpeed, maxSpread):
	target_offset += MAX_SPREAD_PER_SHOT
	SMOOTH_SPEED = growSpeed
	SHRINK_RATE = shrinkSpeed
	MAX_SPREAD_PER_SHOT = maxSpread

#CHATGPT>
