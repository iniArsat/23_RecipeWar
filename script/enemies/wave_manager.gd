extends Node

@export var path_spawners: Array[NodePath] = []
@export var initial_wave_delay := 15.0

# Export time settings di Inspector
@export var time_between_enemies := 1.0
@export var time_between_waves := 15.0  # NEW: Digunakan untuk countdown otomatis

 #Variasi enemy
@export var enemy_Grease_Rat_scene: PackedScene
@export var enemy_Squirrel_Fire_scene: PackedScene
@export var enemy_Monkey_scene: PackedScene
@export var enemy_Mini_Boss_scene: PackedScene
@export var enemy_Chef_Baslik_scene: PackedScene

# CSV Configuration
@export var wave_csv_path: String = "res://data/wave_data.csv"
@export var enemy_csv_path: String = "res://data/enemy_data.csv"

# NEW: Level management
@export var current_level: int = 1

signal victory_achieved()
signal wave_changed(current_wave: int, total_waves: int)
signal wave_countdown_started(seconds: int)
signal wave_countdown_updated(seconds: int)
signal wave_countdown_finished()
signal all_enemies_defeated()
signal wave_completed(wave_number: int)

var waves = []
var enemy_data = {}
var current_wave = 0
var spawning = false
var active_enemies: Array = []
var wave_timer: Timer

func _ready():
	wave_timer = Timer.new()
	add_child(wave_timer)
	
	# Load data dari CSV
	load_data_from_csv()
	
	# NEW: Tidak mulai wave otomatis, tunggu dari Main.gd
	print("⏳ WaveManager siap. Tunggu start dari player...")

func load_data_from_csv():
	# NEW: Load waves berdasarkan level
	var csv_data = CSVWaveLoader.load_waves_from_csv(wave_csv_path)
	if csv_data.size() > 0:
		waves = CSVWaveLoader.get_waves_for_level(csv_data, current_level)
		print("✅ Loaded ", waves.size(), " waves for level ", current_level, " from CSV")
	else:
		# Fallback ke data default jika CSV gagal load
		setup_default_waves()
		print("⚠️ Using default waves data")
	
	enemy_data = EnemyCSVLoader.load_enemy_data_from_csv(enemy_csv_path)
	print("✅ Loaded ", enemy_data.size(), " enemy types from CSV")
	
	wave_changed.emit(current_wave + 1, waves.size())

func setup_default_waves():
	waves = [
		{
			"wave": 1,
			"enemies": [
				{"type": "Grease_Rat", "count": 5},
				{"type": "Squirrel_Fire", "count": 1}
			]
		},
		{
			"wave": 2, 
			"enemies": [
				{"type": "Grease_Rat", "count": 6},
				{"type": "Squirrel_Fire", "count": 2}
			]
		}
	]

# NEW: Fungsi dipanggil dari Main.gd untuk mulai wave
func start_next_wave():
	if spawning:
		return
	if current_wave >= waves.size():
		print("✅ Semua wave selesai")
		victory_achieved.emit() 
		return
	
	var previous_wave = current_wave
	spawning = true
	print("🚀 Wave ", current_wave + 1, " mulai!")

	var wave_data = waves[current_wave]
	wave_changed.emit(current_wave + 1, waves.size())
	await spawn_wave(wave_data)

	# Tunggu semua musuh mati
	await wait_until_all_enemies_dead()
	print("✅ Semua musuh di wave ", current_wave + 1, " telah dikalahkan!")
	
	wave_completed.emit(current_wave + 1)
	current_wave += 1
	spawning = false

	if current_wave >= waves.size():
		print("🎉 VICTORY! Semua %d wave berhasil dikalahkan!" % waves.size())
		victory_achieved.emit()
	# NEW: Wave berikutnya otomatis setelah delay (dikelola Main.gd)
	# Tidak perlu start_next_wave() disini

func spawn_wave(wave_data: Dictionary):
	var spawner_nodes = []
	for spawner_path in path_spawners:
		var spawner = get_node(spawner_path)
		if spawner:
			spawner_nodes.append(spawner)
		else:
			push_error("Spawner not found: " + str(spawner_path))
	
	if spawner_nodes.size() == 0:
		push_error("No valid spawners found!")
		return
	
	var enemies_data = wave_data.get("enemies", [])
	print("Spawning wave with ", enemies_data.size(), " enemy groups")

	for enemy_group in enemies_data:
		var enemy_type = enemy_group["type"]
		var count = enemy_group["count"]
		var spawner_index = enemy_group.get("spawner_index", -1)
		
		print("Spawning ", count, " of ", enemy_type)

		for i in range(count):
			var target_spawner_index = 0
			
			if spawner_index == -1:
				# Mode round-robin ke semua spawner
				target_spawner_index = i % spawner_nodes.size()
			elif spawner_index >= 0 and spawner_index < spawner_nodes.size():
				# Spawn di spawner tertentu
				target_spawner_index = spawner_index
			else:
				# Fallback ke spawner pertama
				target_spawner_index = 0
				print("⚠️ Invalid spawner_index: ", spawner_index)
			
			var enemy = spawn_enemy(enemy_type, spawner_nodes[target_spawner_index])
			if enemy:
				active_enemies.append(enemy)
				if enemy.tree_exited.is_connected(_on_enemy_died):
					enemy.tree_exited.disconnect(_on_enemy_died)
				enemy.tree_exited.connect(_on_enemy_died.bind(enemy))
			
			await get_tree().create_timer(time_between_enemies).timeout

func spawn_enemy(enemy_type: String, spawner: Node) -> Node:
	if not enemy_data.has(enemy_type):
		push_error("Enemy type not found in CSV: " + enemy_type)
		return null
	
	var enemy_scene = get_enemy_scene_by_type(enemy_type)
	if enemy_scene == null:
		push_error("Enemy scene not set in Inspector for type: " + enemy_type)
		return null
	
	var enemy = enemy_scene.instantiate()
	var enemy_info = enemy_data[enemy_type]
	
	# Set stats ke enemy dari CSV data
	if enemy.has_method("apply_csv_values"):
		enemy.health = enemy_info["health"]
		enemy.speed = enemy_info["speed"]
		enemy.coin_reward = enemy_info["coin_reward"]
		enemy.dps_damage = enemy_info["dps_damage"]
		enemy.can_attack_towers = enemy_info["can_attack_towers"]
		enemy.tower_damage = enemy_info["tower_damage"]
		#enemy.nerf_type = enemy_info["nerf_type"]
		#enemy.nerf_power = enemy_info["nerf_power"]
		#enemy.nerf_duration = enemy_info["nerf_duration"]
		
		# Panggil fungsi setup
		enemy.apply_csv_values()
	else:
		push_warning("Enemy does not have apply_csv_values method: " + enemy_type)
	
	var temp_path = spawner.path_scene.instantiate()
	spawner.add_child(temp_path)
	
	var follow = temp_path.get_node("PathFollow2D")
	follow.add_child(enemy)
	
	return enemy

func get_enemy_scene_by_type(enemy_type: String) -> PackedScene:
	match enemy_type:
		"Grease_Rat", "GreaseRat":
			return enemy_Grease_Rat_scene
		"Squirrel_Fire", "SquirrelFire":
			return enemy_Squirrel_Fire_scene
		"Monkey":
			return enemy_Monkey_scene
		"Mini_Boss", "MiniBoss":
			return enemy_Mini_Boss_scene
		"Blind_Bat", "Chef_Baslik":  # TAMBAH INI
			return enemy_Chef_Baslik_scene
		_:
			push_error("Unknown enemy type: " + enemy_type)
			return null
			
func _on_enemy_died(enemy):
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		print("Enemy died, remaining: ", active_enemies.size())

func wait_until_all_enemies_dead():
	while active_enemies.size() > 0:
		await get_tree().process_frame
	all_enemies_defeated.emit()
	print("All enemies cleared from wave")

# NEW: Fungsi untuk mengganti level
func set_level(level: int):
	current_level = level
	reset_wave_manager()

func reset_wave_manager():
	current_wave = -1  # NEW: Reset ke 0, bukan -1
	spawning = false
	active_enemies.clear()
	
	# Hentikan semua proses yang sedang berjalan
	if wave_timer:
		wave_timer.stop()
	
	# Load ulang data untuk level baru
	load_data_from_csv()
	
	print("🔄 WaveManager reset for level ", current_level)

# NEW: Get current wave info
func get_current_wave_info() -> Dictionary:
	if current_wave < waves.size():
		return waves[current_wave]
	return {}

func start_wave_countdown(seconds: int):
	# NEW: Fungsi ini digunakan untuk countdown antar wave
	wave_countdown_started.emit(seconds)
	
	for i in range(seconds, 0, -1):
		wave_countdown_updated.emit(i)
		await get_tree().create_timer(1.0).timeout
	
	wave_countdown_finished.emit()
	
func skip_to_wave(wave_number: int):
	if wave_number > 0 and wave_number <= waves.size():
		current_wave = wave_number - 1
		reset_wave_manager()
		start_next_wave()
