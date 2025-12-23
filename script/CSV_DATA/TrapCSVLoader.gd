extends Node

class_name TrapCSVLoader

static func load_trap_data_from_csv(file_path: String) -> Dictionary:
	var trap_data_dict = {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load trap CSV file: " + file_path)
		return trap_data_dict
	
	# Baca header
	var headers = file.get_csv_line()
	
	# Baca data
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= headers.size() and line[0] != "":
			var trap_type = line[0]
			var data = {
				"damage": float(line[1]),
				"radius": float(line[2]),
				"cooldown": float(line[3]),
				"effect_duration": float(line[4]),
				"effect_type": line[5]
			}
			trap_data_dict[trap_type] = data
	
	file.close()
	print("✅ Loaded ", trap_data_dict.size(), " trap types from CSV")
	return trap_data_dict
