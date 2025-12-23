extends Node

var normal_speed = 1.0
var fast_speed = 2.0
var current_speed = 1.0
var is_paused = false

signal game_speed_changed(speed_multiplier)
signal game_paused(is_paused)

func toggle_speed():
	if is_paused:
		return
	if current_speed == normal_speed:
		set_game_speed(fast_speed)
	else:
		set_game_speed(normal_speed)

func set_game_speed(speed_multiplier: float):
	current_speed = speed_multiplier
	Engine.time_scale = speed_multiplier
	emit_signal("game_speed_changed", speed_multiplier)
	
func toggle_pause():
	is_paused = !is_paused
	if is_paused:
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = current_speed
	emit_signal("game_paused", is_paused)
	print("⏸️ Game Paused: ", is_paused)
		
func is_game_paused() -> bool:
	return is_paused
	
func get_current_speed() -> float:
	return current_speed

func is_fast_forward() -> bool:
	return current_speed == fast_speed

# NEW: Reset speed ketika game dimulai ulang
func reset_speed():
	is_paused = false
	set_game_speed(normal_speed)
