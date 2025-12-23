extends Node

const SAVE_PATH = "user://savegame.save"
const VERSION = "1.1"

var save_data = {
	"version": VERSION,
	"completed_levels": [],      # Level yang sudah selesai
	"highest_level": 1,          # Level tertinggi yang bisa diakses
	"total_stars": 0,            # TOTAL bintang yang terkumpul (akumulasi)
	"level_stars": {},           # Bintang per level (terbaik)
	"unlocked_towers": ["Stove_Cannon","Chilli_Launcher"],
	"settings": {
		"music_volume": 0.5,
		"sfx_volume": 1.0
	}
}

func _ready():
	load_game()
	#testing
	#save_data["highest_level"] = 999  # 🎯 UNLOCK SEMUA LEVEL
	#save_data["completed_levels"] = [1, 2, 3, 4, 5]  # 🎯 MARK SEMUA SELESAI
	#
	## Unlock semua tower
	#save_data["unlocked_towers"] = ["Stove_Cannon", "Chilli_Launcher", "Ice_Chiller", "Garlic_Barrier", "Pepper_Grinder"]
	#
	##Banyak stars untuk beli apapun
	#save_data["total_stars"] = 999
	print("💾 SaveManager loaded - Total Stars: ", save_data["total_stars"])
	_ensure_unlocked_towers()
	if MusicPlayer:
		MusicPlayer.load_volume_settings()

# Save game
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save game")
		return
	
	file.store_var(save_data)
	file.close()
	print("💾 Game saved - Total Stars: ", save_data["total_stars"])

# Load game
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("📂 No save file found, creating default")
		save_game()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to load game")
		return
	
	save_data = file.get_var()
	file.close()
	_ensure_unlocked_towers()
	print("📂 Game loaded - Total Stars: ", save_data["total_stars"])

func _ensure_unlocked_towers():
	if not "unlocked_towers" in save_data:
		save_data["unlocked_towers"] = ["Stove_Cannon"]
		print("⚠️ unlocked_towers tidak ditemukan, buat baru")

# Complete level dengan stars
func complete_level(level: int, stars: int):
	print("🎮 Completing level ", level, " with ", stars, " stars")
	
	# Update completed levels
	if not level in save_data["completed_levels"]:
		save_data["completed_levels"].append(level)
		save_data["completed_levels"].sort()
	
	# Update highest level
	if level >= save_data["highest_level"]:
		save_data["highest_level"] = level + 1
	
	# AKUMULASI TOTAL STARS (selalu tambah, tidak replace)
	save_data["total_stars"] += stars
	print("⭐ Added ", stars, " stars to total (now: ", save_data["total_stars"], ")")
	
	# Simpan best stars per level (optional, untuk tampilan di select level)
	if not save_data["level_stars"].has(level):
		save_data["level_stars"][level] = stars
	else:
		# Hanya simpan jika lebih tinggi dari sebelumnya
		if stars > save_data["level_stars"][level]:
			save_data["level_stars"][level] = stars
	
	save_game()

func buy_tower(tower_name: String):
	if not "unlocked_towers" in save_data:
		save_data["unlocked_towers"] = ["Stove_Cannon"]
	if not tower_name in save_data["unlocked_towers"]:
		save_data["unlocked_towers"].append(tower_name)
		save_game()
		print("✅ Tower dibeli: " + tower_name)
		return true
	return false

func add_consumable(item_name: String, amount: int = 1):
	if not "consumables" in save_data:
		save_data["consumables"] = {}
	
	if not item_name in save_data["consumables"]:
		save_data["consumables"][item_name] = 0
	
	save_data["consumables"][item_name] += amount

func get_consumable_amount(item_name: String) -> int:
	if not "consumables" in save_data:
		save_data["consumables"] = {}
	
	if not item_name in save_data["consumables"]:
		return 0
	
	return save_data["consumables"][item_name]

func use_consumable(item_name: String, amount: int = 1) -> bool:
	if not "consumables" in save_data:
		save_data["consumables"] = {}
	
	if not item_name in save_data["consumables"]:
		return false
	
	if save_data["consumables"][item_name] >= amount:
		save_data["consumables"][item_name] -= amount
		return true
	
	return false
	
func has_tower(tower_name: String) -> bool:
	return tower_name in save_data["unlocked_towers"]
	
func get_total_stars() -> int:
	return save_data["total_stars"]

# Get stars untuk level tertentu
func get_level_stars(level: int) -> int:
	if save_data["level_stars"].has(level):
		return save_data["level_stars"][level]
	return 0

# Level access check
func is_level_accessible(level: int) -> bool:
	return level <= save_data["highest_level"]

func is_level_completed(level: int) -> bool:
	return level in save_data["completed_levels"]

func get_highest_accessible_level() -> int:
	return save_data["highest_level"]

func get_completed_levels() -> Array:
	return save_data["completed_levels"]

# Reset progress
func reset_progress():
	save_data = {
		"version": VERSION,
		"completed_levels": [],
		"highest_level": 1,
		"total_stars": 0,
		"level_stars": {},
		"settings": save_data["settings"]  # Keep settings
	}
	save_game()
	print("🔄 Progress reset")
