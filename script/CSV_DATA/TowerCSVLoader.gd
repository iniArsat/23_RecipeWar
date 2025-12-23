extends Node

class_name TowerCSVLoader

static func load_tower_data_from_csv(file_path: String) -> Dictionary:
	var tower_data_dict = {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load tower CSV file: " + file_path)
		return tower_data_dict
	
	# Baca header
	var headers = file.get_csv_line()
	
	# Baca data
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= headers.size() and line[0] != "":
			var tower_type = line[0]
			var data = {
				"bullet_speed": float(line[1]),
				# Data damage untuk tiap level
				"damage_level1": float(line[2]),
				"damage_level2": float(line[3]),
				"damage_level3": float(line[4]),
				# Data cooldown untuk tiap level
				"cooldown_level1": float(line[5]),
				"cooldown_level2": float(line[6]),
				"cooldown_level3": float(line[7]),
				# Data range untuk tiap level
				"range_level1": float(line[8]),
				"range_level2": float(line[9]),
				"range_level3": float(line[10]),
				# Cost
				"base_cost": int(line[11]),
				"upgrade_cost_level2": int(line[12]),
				"upgrade_cost_level3": int(line[13]),
				"description": float(line[14])
			}
			tower_data_dict[tower_type] = data
	
	file.close()
	print("✅ Loaded ", tower_data_dict.size(), " tower types from CSV")
	return tower_data_dict
