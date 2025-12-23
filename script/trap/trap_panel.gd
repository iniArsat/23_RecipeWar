extends Panel

@export var trap_csv_path: String = "res://data/trap_data.csv"
@export var chili_bomb_trap_scene: PackedScene
@export var net_trap_scene: PackedScene
@export var gelatin_bounce_trap_scene: PackedScene

var trap_data = {}
var temp_trap = null
var is_dragging_trap = false
@export var selected_trap_type: String = "Chili_Bomb_Trap"
var trap_owned_count: int = 0
var trap_item_name: String = "chilli_bomb"
var has_deducted_from_inventory: bool = false

@onready var name_label: Label = $Popup/PopupLabel
@onready var popup: Panel = $Popup


func _ready():
	load_trap_data()
	_update_trap_owned_count()
	if popup:
		popup.visible = false

func _process(delta):
	# Update setiap frame (atau gunakan timer untuk efisiensi)
	_check_trap_availability()

func load_trap_data():
	trap_data = TrapCSVLoader.load_trap_data_from_csv(trap_csv_path)

func get_trap_cost(trap_type: String) -> float:
	if trap_data.has(trap_type):
		return trap_data[trap_type].get("base_cost", 75)
	return 9999

func _update_trap_owned_count():
	if SaveManager.has_method("get_consumable_amount"):
		match selected_trap_type:
			"Chili_Bomb_Trap":
				trap_item_name = "chilli_bomb"
			"Net_Trap":
				trap_item_name = "net_trap"
			"Gelatin_Bounce_Trap":  # TAMBAH INI
				trap_item_name = "gelatin_bounce"
			_:
				trap_item_name = "chilli_bomb"
		trap_owned_count = SaveManager.get_consumable_amount(trap_item_name)
		print(trap_item_name + " owned: ", trap_owned_count)
		# Update UI atau nonaktifkan jika count = 0
		_update_ui_based_on_count()

# Fungsi baru: Update UI berdasarkan jumlah trap
func _update_ui_based_on_count():
	if trap_owned_count <= 0:
		# Nonaktifkan panel atau sembunyikan
		visible = false
		# Atau hapus diri sendiri dari parent
		# queue_free()
		
		# Optional: Tampilkan label "No traps available"
		print("No traps available, panel hidden")
	else:
		visible = true
		# Update text untuk menampilkan jumlah
		_update_count_display()

# Fungsi baru: Update tampilan jumlah trap
func _update_count_display():
	# Cari label di dalam panel untuk menampilkan jumlah
	var count_label = get_node_or_null("CountLabel")
	if count_label:
		count_label.text = str(trap_owned_count)

# Fungsi baru: Cek ketersediaan trap secara berkala
func _check_trap_availability():
	if SaveManager.has_method("get_consumable_amount"):
		var current_count = SaveManager.get_consumable_amount(trap_item_name)
		
		# Jika jumlah berubah, update
		if current_count != trap_owned_count:
			trap_owned_count = current_count
			_update_ui_based_on_count()
			
			# Jika jumlah 0, hapus diri dari scene
			if trap_owned_count <= 0:
				_remove_panel_when_empty()

# Fungsi baru: Hapus panel ketika trap habis
func _remove_panel_when_empty():
	print("Trap count is 0, removing panel...")
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if trap_owned_count <= 0:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var trap_cost = get_trap_cost(selected_trap_type)
			if GameManager.coin >= trap_cost and trap_owned_count > 0:
				spawn_trap_drag()
			else:
				print("Koin tidak cukup atau trap habis!")
		
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# RELEASE - baru kurangi inventory jika valid
			release_trap()
	
	elif event is InputEventMouseMotion and is_dragging_trap and temp_trap:
		temp_trap.global_position = event.global_position
		_update_drag_trap_color()

func spawn_trap_drag():
	if trap_owned_count <= 0:
		print("No traps available!")
		return
	if not trap_data.has(selected_trap_type):
		push_error("Trap type not found: " + selected_trap_type)
		return
	
	var trap_cost = get_trap_cost(selected_trap_type)
	if GameManager.coin < trap_cost:
		print("Koin tidak cukup!")
		return
		
	has_deducted_from_inventory = false
		
	var trap_scene = get_trap_scene_by_type(selected_trap_type)
	if trap_scene == null:
		push_error("Trap scene not set in Inspector for type: " + selected_trap_type)
		return
	
	var trap_info = trap_data[selected_trap_type]
	
	temp_trap = trap_scene.instantiate()
	add_child(temp_trap)
	temp_trap.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Setup trap data dari CSV
	if temp_trap.has_method("setup_from_data"):
		temp_trap.setup_from_data(selected_trap_type, trap_info)
	
	if temp_trap.has_method("start_drag"):
		temp_trap.start_drag()
	is_dragging_trap = true

func get_trap_scene_by_type(trap_type: String) -> PackedScene:
	match trap_type:
		"Chili_Bomb_Trap":
			return chili_bomb_trap_scene
		"Net_Trap":
			return net_trap_scene
		"Gelatin_Bounce_Trap":  # TAMBAH INI
			return gelatin_bounce_trap_scene
		_:
			return null

func release_trap():
	if temp_trap:
		if is_valid_trap_position(temp_trap.global_position):
			var trap_cost = get_trap_cost(selected_trap_type)
			
			if GameManager.coin >= trap_cost:
				# KURANGI KOIN
				GameManager.coin = trap_cost
				GameManager.emit_signal("update_coin", GameManager.coin)
				
				var item_to_use = ""
				match selected_trap_type:
					"Chili_Bomb_Trap":
						item_to_use = "chilli_bomb"
					"Net_Trap":
						item_to_use = "net_trap"
					"Gelatin_Bounce_Trap":  # TAMBAH INI
						item_to_use = "gelatin_bounce"
				
				# KURANGI INVENTORY - HANYA JIKA POSISI VALID
				if SaveManager.has_method("use_consumable") and item_to_use != "":
					if SaveManager.use_consumable(trap_item_name, 1):
						has_deducted_from_inventory = true
						trap_owned_count -= 1
						SaveManager.save_game()
						print("✅ " + item_to_use + " deducted. Remaining: " + str(trap_owned_count))
				
				# TEMPATKAN TRAP DI SCENE
				var main_scene = get_tree().current_scene
				if main_scene:
					var parent_node = main_scene.get_node_or_null("Towers")
					if not parent_node:
						parent_node = Node2D.new()
						parent_node.name = "Traps"
						main_scene.add_child(parent_node)
					
					remove_child(temp_trap)
					parent_node.add_child(temp_trap)
					
					temp_trap.global_position = get_global_mouse_position()
					
					GameManager.placed_traps.append(temp_trap)
					
					temp_trap.process_mode = Node.PROCESS_MODE_INHERIT
					if temp_trap.has_method("stop_drag"):
						temp_trap.stop_drag()
					
					print("✅ Trap placed successfully!")
					
					# UPDATE UI SETELAH BERHASIL DROP
					_update_count_display()
				else:
					# Jika tidak ada scene, kembalikan inventory
					if has_deducted_from_inventory:
						_refund_trap_to_inventory()
					temp_trap.queue_free()
			else:
				print("Not enough coins!")
				temp_trap.queue_free()
		else:
			# POSISI TIDAK VALID - tidak kurangi inventory
			print("❌ Invalid position, trap cancelled")
			temp_trap.queue_free()
		
		temp_trap = null
	
	is_dragging_trap = false
	
	# Cek setelah release
	_check_if_should_remove_panel()

func _refund_trap_to_inventory():
	# Kembalikan trap ke inventory jika gagal ditempatkan
	if has_deducted_from_inventory:
		if SaveManager.has_method("add_consumable"):
			SaveManager.add_consumable(trap_item_name, 1)
			trap_owned_count += 1
			has_deducted_from_inventory = false
			SaveManager.save_game()
			print("🔄 Trap refunded to inventory")

func _check_if_should_remove_panel():
	# Cek apakah masih ada trap
	if trap_owned_count <= 0:
		# Tunggu sedikit sebelum menghapus (biarkan animasi selesai)
		await get_tree().create_timer(0.1).timeout
		
		# Hapus panel
		print("🛑 No traps left, removing panel...")
		queue_free()
		
func is_valid_trap_position(pos: Vector2) -> bool:
	var in_valid_trap_area = false
	for area in GameManager.valid_trap_areas:
		if area is Area2D:
			var polygon = area.get_node_or_null("CollisionPolygon2D")
			if polygon and polygon.polygon.size() > 0:
				var local_pos = area.to_local(pos)
				if Geometry2D.is_point_in_polygon(local_pos, polygon.polygon):
					in_valid_trap_area = true
					break
	
	if not in_valid_trap_area:
		print("❌ Not in valid TRAP area")
		return false
	
	# 2. Cek invalid TRAP area
	for area in GameManager.invalid_trap_areas:
		if area is Area2D:
			var polygon = area.get_node_or_null("CollisionPolygon2D")
			if polygon and polygon.polygon.size() > 0:
				var local_pos = area.to_local(pos)
				if Geometry2D.is_point_in_polygon(local_pos, polygon.polygon):
					print("❌ In invalid TRAP area")
					return false
	
	# 3. Cek jarak dengan trap lain
	if not is_trap_position_valid(pos):
		print("❌ Too close to another trap")
		return false
	
	# 4. Cek jarak dengan tower (opsional)
	for tower in GameManager.placed_towers:
		if is_instance_valid(tower):
			var distance = pos.distance_to(tower.global_position)
			if distance < 30:  # Minimal jarak dari tower
				print("❌ Too close to tower")
				return false
				
	print("✅ Valid trap position")
	return true

func is_trap_position_valid(pos: Vector2) -> bool:
	# Cek jarak dengan trap lain
	for trap in GameManager.placed_traps:
		if is_instance_valid(trap):
			var distance = pos.distance_to(trap.global_position)
			if distance < GameManager.min_trap_distance:
				return false
	
	# Cek jarak dengan tower (opsional)
	for tower in GameManager.placed_towers:
		if is_instance_valid(tower):
			var distance = pos.distance_to(tower.global_position)
			if distance < 50:  # Minimal jarak dari tower
				return false
				
	return true

func _update_drag_trap_color():
	if temp_trap:
		if is_valid_trap_position(temp_trap.global_position):
			temp_trap.modulate = Color.WHITE
		else:
			temp_trap.modulate = Color.RED

func set_trap_type(trap_type: String):
	if trap_data.has(trap_type):
		selected_trap_type = trap_type
		
func update_count(count: int):
	# Update display count
	var count_label = $CountLabel
	if count_label:
		count_label.text = "x" + str(count)
func _on_trap_purchased():
	_update_trap_owned_count()

func _on_mouse_entered() -> void:
	if popup:
		popup.visible = true
		name_label.text = selected_trap_type.replace("_", " ")

func _on_mouse_exited() -> void:
	if popup:
		popup.visible = false
