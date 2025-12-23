extends Panel

@export var tower_csv_path: String = "res://data/tower_data.csv"
@onready var tidak_cukup: Label = $TidakCukup

@export var stove_cannon_scene: PackedScene
@export var chilli_launcher_scene: PackedScene
@export var ice_chiller_scene: PackedScene
@export var garlic_barrier_scene: PackedScene
@export var pepper_grinder_scene: PackedScene
@onready var tower_panel: Panel = $"."
@onready var name_label: Label = $Popup/PopupLabel
@onready var popup: Panel = $Popup
var is_popup_enabled := true

# NEW: Hanya butuh 1 sprite reference
#@onready var selected_tower_sprite: Sprite2D = $CanUpgrade

var tower_data = {}
var temp_tower = null
var is_dragging = false
@export var selected_tower_type: String = "Stove_Cannon"
var invalid_drop_areas: Array = []

func _ready():
	load_tower_data()
	# NEW: Connect ke signal update coin
	GameManager.update_coin.connect(_on_coins_changed)
	if popup:
		popup.visible = false
	# Update visibilitas awal
	#_update_sprite_visibility()
	#_update_sprite_color()

func _on_coins_changed(new_amount: int):
	pass
	# NEW: Update visibilitas sprite ketika koin berubah
	#_update_sprite_visibility()
	#_update_sprite_color()

func load_tower_data():
	tower_data = TowerCSVLoader.load_tower_data_from_csv(tower_csv_path)
	if tower_data.size() > 0:
		print("✅ Loaded ", tower_data.size(), " tower types from CSV")
	else:
		push_error("Failed to load tower data from CSV")

func get_tower_cost(tower_type: String) -> float:
	if tower_data.has(tower_type):
		return tower_data[tower_type].get("base_cost", 100)
	return 9999

# NEW: Fungsi sederhana untuk update visibilitas sprite
#func _update_sprite_visibility():
	#var current_coins = GameManager.coin
	#var tower_cost = get_tower_cost(selected_tower_type)
	#
	#if selected_tower_sprite:
		#selected_tower_sprite.visible = current_coins >= tower_cost

func _on_mouse_entered():
	if popup and is_popup_enabled:
		name_label.text = selected_tower_type.replace("_", " ")
		popup.visible = true

func _on_mouse_exited():
	if popup and is_popup_enabled:
		popup.visible = false

func set_popup_enabled(enabled: bool):
	is_popup_enabled = enabled
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var tower_cost = get_tower_cost(selected_tower_type)
			if GameManager.coin >= tower_cost:
				spawn_tower_drag()
			else:
				print("Koin tidak cukup untuk membeli tower!")
				show_not_enough_coin_label()
		
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			release_tower()
	
	elif event is InputEventMouseMotion and is_dragging and temp_tower:
		temp_tower.global_position = event.global_position
		_update_drag_tower_color()
		
func _update_drag_tower_color():
	if temp_tower:
		if is_valid_drop_position(temp_tower.global_position):
			temp_tower.modulate = Color.WHITE  # Posisi valid - warna normal
		else:
			temp_tower.modulate = Color.RED
			
func spawn_tower_drag():
	if not tower_data.has(selected_tower_type):
		push_error("Tower type not found: " + selected_tower_type)
		return
	
	var tower_cost = get_tower_cost(selected_tower_type)
	if GameManager.coin < tower_cost:
		print("Koin tidak cukup!")
		return
	
	# DAPATKAN SCENE DARI @export VARIABLE DI INSPECTOR
	var tower_scene = get_tower_scene_by_type(selected_tower_type)
	if tower_scene == null:
		push_error("Tower scene not set in Inspector for type: " + selected_tower_type)
		return
	
	var tower_info = tower_data[selected_tower_type]
	
	temp_tower = tower_scene.instantiate()
	add_child(temp_tower)
	temp_tower.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Setup tower data dari CSV
	if temp_tower.has_method("setup_from_data"):
		temp_tower.setup_from_data(selected_tower_type, tower_info)
	
	if temp_tower.has_method("start_drag"):
		temp_tower.start_drag()
	is_dragging = true

func get_tower_scene_by_type(tower_type: String) -> PackedScene:
	match tower_type:
		"Stove_Cannon":
			return stove_cannon_scene
		"Chilli_Launcher":
			return chilli_launcher_scene
		"Ice_Chiller":
			return ice_chiller_scene
		"Garlic_Barrier":
			return garlic_barrier_scene
		"Pepper_Grinder":
			return pepper_grinder_scene
		_:
			return null
			
func release_tower():
	if temp_tower:
		var drop_position = temp_tower.global_position
		# Cari valid drop area terdekat
		var nearest_valid_area = _find_nearest_valid_drop_area(drop_position)
		# Jika ada valid drop area di dekatnya, snap ke tengah area
		if nearest_valid_area:
			var center_position = _get_area_center(nearest_valid_area)
			if center_position:
				drop_position = center_position
				
		if is_valid_drop_position(temp_tower.global_position):
			var tower_cost = get_tower_cost(selected_tower_type)
			
			# Kurangi koin
			GameManager.coin -= tower_cost
			GameManager.emit_signal("update_coin", GameManager.coin)
			
			var main_scene = get_tree().current_scene
			if main_scene and main_scene.has_node("Towers"):
				var towers_parent = main_scene.get_node("Towers")
				
				remove_child(temp_tower)
				towers_parent.add_child(temp_tower)
				temp_tower.global_position = drop_position
				
				# NEW: Tambahkan tower ke daftar tower yang sudah terpasang
				GameManager.placed_towers.append(temp_tower)
				GameManager.emit_signal("tower_placed", temp_tower)
				
				print("✅ Tower ", selected_tower_type, " berhasil dipasang")
			else:
				temp_tower.queue_free()
			
			temp_tower.process_mode = Node.PROCESS_MODE_INHERIT
			if temp_tower.has_method("stop_drag"):
				temp_tower.stop_drag()
		else:
			print("Drop di area tidak valid → tower dihapus")
			temp_tower.queue_free()
		temp_tower = null
	is_dragging = false

func _find_nearest_valid_drop_area(pos: Vector2) -> Area2D:
	var nearest_area = null
	var min_distance = INF
	
	for area in GameManager.valid_drop_areas:
		if area is Area2D:
			var polygon = area.get_node_or_null("CollisionPolygon2D")
			if polygon and polygon.polygon.size() > 0:
				var local_pos = area.to_local(pos)
				if Geometry2D.is_point_in_polygon(local_pos, polygon.polygon):
					# Jika posisi sudah dalam area, langsung return area ini
					return area
				
				# Jika tidak dalam area, hitung jarak ke area
				var area_center = _get_area_center(area)
				if area_center:
					var distance = pos.distance_to(area_center)
					if distance < min_distance:
						min_distance = distance
						nearest_area = area
	
	return nearest_area

# Fungsi untuk mendapatkan titik tengah area
func _get_area_center(area: Area2D) -> Vector2:
	var polygon = area.get_node_or_null("CollisionPolygon2D")
	if not polygon or polygon.polygon.size() == 0:
		return Vector2.ZERO
	
	# Hitung bounding box dari polygon
	var min_point = polygon.polygon[0]
	var max_point = polygon.polygon[0]
	
	for point in polygon.polygon:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	
	# Hitung titik tengah
	var local_center = (min_point + max_point) / 2
	# Konversi ke koordinat global
	return area.to_global(local_center)
	
func is_valid_drop_position(pos: Vector2) -> bool:
	var in_valid_area = false
	for area in GameManager.valid_drop_areas:
		if area is Area2D:
			var polygon = area.get_node_or_null("CollisionPolygon2D")
			if polygon and polygon.polygon.size() > 0:
				var local_pos = area.to_local(pos)
				if Geometry2D.is_point_in_polygon(local_pos, polygon.polygon):
					in_valid_area = true
					break
	
	if not in_valid_area:
		return false
	
	# Cek area terlarang (seperti sebelumnya)
	for area in GameManager.invalid_drop_areas:
		if area is Area2D:
			var polygon = area.get_node_or_null("CollisionPolygon2D")
			if polygon and polygon.polygon.size() > 0:
				var local_pos = area.to_local(pos)
				if Geometry2D.is_point_in_polygon(local_pos, polygon.polygon):
					return false
	
	# Cek jarak dengan tower lain
	if not is_tower_position_valid(pos):
		return false
		
	return true
func is_tower_position_valid(pos: Vector2) -> bool:
	for tower in GameManager.placed_towers:
		if is_instance_valid(tower):
			# Hitung jarak antara posisi drop dan tower yang sudah ada
			var distance = pos.distance_to(tower.global_position)
			if distance < GameManager.min_tower_distance:
				return false
	return true
func show_not_enough_coin_label():
	tidak_cukup.visible = true
	tidak_cukup.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(tidak_cukup, "modulate:a", 0.0, 1.5)
	await tween.finished
	tidak_cukup.visible = false

#func _update_sprite_color():
	#if selected_tower_sprite:
		#var tower_cost = get_tower_cost(selected_tower_type)
		#if GameManager.coin >= tower_cost:
			#tower_panel.modulate = Color.WHITE  # Warna normal
		#else:
			#tower_panel.modulate = Color.GRAY
			#
# Fungsi untuk UI buttons memilih tower type
func set_tower_type(tower_type: String):
	if tower_data.has(tower_type):
		selected_tower_type = tower_type
		print("Selected tower: ", tower_type)
		if name_label:
			name_label.text = tower_type.replace("_", " ")
		#_update_sprite_color()
		## NEW: Update visibilitas sprite setelah ganti tower type
		#_update_sprite_visibility()
	else:
		push_error("Tower type not found: " + tower_type)
