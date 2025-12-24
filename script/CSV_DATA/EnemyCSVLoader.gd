extends Node

class_name EnemyCSVLoader

static func load_enemy_data_from_csv(file_path: String) -> Dictionary:
	var enemy_data_dict = {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load enemy CSV file: " + file_path)
		return enemy_data_dict
	
	# Baca header
	var headers = file.get_csv_line()
	
	# Baca data
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= headers.size() and line[0] != "":
			var enemy_type = line[0]
			var data = {
				"health": float(line[1]),
				"speed": float(line[2]),
				"coin_reward": int(line[3]),
				"dps_damage": int(line[4]),
				"can_attack_towers": bool(int(line[5])),
				"tower_damage": float(line[6]),
				"nerf_type": line[7],
				"nerf_power": float(line[8]),
				"nerf_duration": float(line[9]),
				"description": String(line[10]),
				"type": String(line[11]),
				"ability": String(line[12]),
				"image_path": String(line[13])
				
			}
			enemy_data_dict[enemy_type] = data
	
	file.close()
	return enemy_data_dict

# Fungsi untuk load scene dari path
static func load_enemy_scene(scene_path: String) -> PackedScene:
	var scene = load(scene_path)
	if scene == null:
		push_error("Failed to load enemy scene: " + scene_path)
	return scene
