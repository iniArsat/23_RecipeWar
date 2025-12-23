extends Node2D


var coin: int = 0
var health_player: int = 100
var initial_coin_per_level: int = 10000

signal update_coin(new_amount: int)
signal update_health(new_amount: int)
signal game_over()
signal base_damaged()
signal tower_placed(tower_instance)
signal tower_upgraded(tower_instance)
var invalid_drop_areas: Array = []
var invalid_trap_areas: Array = []
var valid_drop_areas: Array = []
var valid_trap_areas: Array = []
var is_game_over = false
var placed_towers: Array = []  # Menyimpan referensi semua tower yang sudah terpasang
var min_tower_distance: float = 80.0 
var current_level: int = 1
var should_open_store = false

var placed_traps: Array = []  # NEW: Menyimpan referensi trap yang sudah terpasang
var min_trap_distance: float = 0.0  # NEW: Jarak minimum antar trap

signal trap_placed(trap_instance)

func _ready():
	# Reset flag setiap game mulai
	should_open_store = false

func set_level(level: int):
	current_level = level
	match level:
		1:
			initial_coin_per_level = 100
		2:
			initial_coin_per_level = 120
		3:
			initial_coin_per_level = 140
		4:
			initial_coin_per_level = 160
		5:
			initial_coin_per_level = 180
		_:
			initial_coin_per_level = 100  # Default
	reset_game()
	
func _add_coin(amount: int) -> void:
	coin += amount
	emit_signal("update_coin", coin)
	
func _take_damage(amount: int) -> void:
	if is_game_over:
		return
		
	var new_health = health_player - amount
	new_health = max(0, new_health)  # Pastikan tidak minus
	
	health_player = new_health
	emit_signal("update_health", health_player)
	emit_signal("base_damaged")
	
	if health_player <= 0:
		health_player = 0
		_game_over()

func toggle_game_speed():
	GameSpeedManager.toggle_speed()
	
func toggle_pause():
	GameSpeedManager.toggle_pause()
# Fungsi untuk mendapatkan status speed
func is_fast_forward() -> bool:
	return GameSpeedManager.is_fast_forward()
	
func is_game_paused() -> bool:
	return GameSpeedManager.is_game_paused()

func reset_game():
	coin = initial_coin_per_level
	health_player = 100
	is_game_over = false
	placed_towers.clear()
	GameSpeedManager.reset_speed()
	emit_signal("update_coin", coin)
	emit_signal("update_health", health_player)
	
func _game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	GameSpeedManager.set_game_speed(0.0)  # NEW: Pause game
	emit_signal("game_over")
	print("GameOver")
	
