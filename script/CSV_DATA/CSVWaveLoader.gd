extends Node

class_name CSVWaveLoader

static func load_waves_from_csv(file_path: String) -> Dictionary:
	var waves_dict = {}  # Format: {level: {wave: [enemies]}}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load CSV file: " + file_path)
		return waves_dict
	
	# Baca header
	var header = file.get_csv_line()
	print("CSV Header: ", header)
	
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= 5 and line[0] != "":
			var level = int(line[0])
			var wave = int(line[1])
			var enemy_type = line[2]
			var count = int(line[3])
			var spawner_index = int(line[4])
			
			# Initialize level jika belum ada
			if not waves_dict.has(level):
				waves_dict[level] = {}
			
			# Initialize wave jika belum ada
			if not waves_dict[level].has(wave):
				waves_dict[level][wave] = []
			
			# Tambahkan enemy ke wave
			waves_dict[level][wave].append({
				"type": enemy_type,
				"count": count,
				"spawner_index": spawner_index
			})
	
	file.close()
	print("Loaded waves for levels: ", waves_dict.keys())
	return waves_dict

static func get_waves_for_level(csv_data: Dictionary, level: int) -> Array:
	if not csv_data.has(level):
		push_error("Level " + str(level) + " not found in CSV data")
		return []
	
	var waves_array = []
	var level_data = csv_data[level]
	
	# Convert ke format yang diharapkan WaveManager
	var wave_numbers = level_data.keys()
	wave_numbers.sort()
	
	for wave_num in wave_numbers:
		waves_array.append({
			"wave": wave_num,
			"enemies": level_data[wave_num]
		})
	
	print("Level ", level, " has ", waves_array.size(), " waves")
	return waves_array

# OLD: Keep for backward compatibility
static func convert_to_wave_format(csv_data: Array) -> Array:
	# Untuk kompatibilitas dengan kode lama
	var waves_array = []
	for data in csv_data:
		waves_array.append({
			"enemies": data["enemies"]
		})
	return waves_array
