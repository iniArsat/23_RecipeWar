extends Panel

@onready var button_enemies: Button = $HBoxContainer/Button_Enemies
@onready var button_tower: Button = $HBoxContainer/Button_Tower
@onready var button_trap: Button = $HBoxContainer/Button_Trap
@onready var panel_enemies: Panel = $Panel_enemies
@onready var panel_tower: Panel = $Panel_tower
@onready var panel_trap: Panel = $Panel_trap
@onready var panel_encyclopedia: Panel = $"."

# Container untuk button
@onready var enemies_container: VBoxContainer = $Panel_enemies/VBoxContainer
@onready var tower_container: VBoxContainer = $Panel_tower/VBoxContainer
@onready var trap_container: VBoxContainer = $Panel_trap/VBoxContainer

# Scene untuk button template
@export var enemy_button_scene: PackedScene
@export var tower_button_scene: PackedScene
@export var trap_button_scene: PackedScene

# Panel untuk menampilkan detail
@onready var detail_panel: Panel = $Detail_Panel
@onready var detail_image: Sprite2D = $Detail_Panel/icon
@onready var detail_title: Label = $Detail_Panel/tittle
@onready var detail_type: Label = $Detail_Panel/type
@onready var detail_ability: Label = $Detail_Panel/ability
@onready var detail_description: RichTextLabel = $Detail_Panel/description

# Data dari CSV
var enemies_data: Array = []
var towers_data: Array = []
var traps_data: Array = []

func _ready():
	# Load data dari CSV
	load_csv_data()
	
	# Setup initial state
	panel_enemies.visible = true
	panel_tower.visible = false
	panel_trap.visible = false
	detail_panel.visible = false
	
	# Focus ke button enemies
	button_enemies.grab_focus()
	
	# Generate buttons untuk enemies (default)
	generate_enemy_buttons()
	
	# Auto-select enemy pertama
	call_deferred("_auto_select_first_enemy")

func load_csv_data():
	# Load enemies data
	enemies_data = _load_csv("res://data/enemy_data.csv")
	print("✅ Loaded %d enemies from CSV" % enemies_data.size())
	
	# Load towers data
	towers_data = _load_csv("res://data/tower_data.csv")
	print("✅ Loaded %d towers from CSV" % towers_data.size())
	
	# Load traps data
	traps_data = _load_csv("res://data/trap_data.csv")
	print("✅ Loaded %d traps from CSV" % traps_data.size())

func _load_csv(file_path: String) -> Array:
	var data = []
	
	if not FileAccess.file_exists(file_path):
		print("❌ CSV file not found: ", file_path)
		return data
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	# Baca header
	var headers_line = file.get_csv_line()
	var headers = []
	for header in headers_line:
		headers.append(header.strip_edges())
	
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= headers.size():
			var entry = {}
			for i in range(headers.size()):
				var value = line[i].strip_edges() if i < line.size() else ""
				entry[headers[i]] = value
			data.append(entry)
	
	file.close()
	return data

func generate_enemy_buttons():
	# Clear existing buttons
	_clear_container(enemies_container)
	
	# Create buttons untuk setiap enemy
	for enemy_data in enemies_data:
		if enemy_button_scene:
			var button_instance = enemy_button_scene.instantiate()
			
			# Setup button dengan data enemy
			_setup_enemy_button(button_instance, enemy_data)
			
			enemies_container.add_child(button_instance)
	
	print("✅ Generated %d enemy buttons" % enemies_data.size())

func generate_tower_buttons():
	# Clear existing buttons
	_clear_container(tower_container)
	
	# Create buttons untuk setiap tower
	for tower_data in towers_data:
		if tower_button_scene:
			var button_instance = tower_button_scene.instantiate()
			
			# Setup button dengan data tower
			_setup_tower_button(button_instance, tower_data)
			
			tower_container.add_child(button_instance)
	
	print("✅ Generated %d tower buttons" % towers_data.size())

func generate_trap_buttons():
	# Clear existing buttons
	_clear_container(trap_container)
	
	# Create buttons untuk setiap trap
	for trap_data in traps_data:
		if trap_button_scene:
			var button_instance = trap_button_scene.instantiate()
			
			# Setup button dengan data trap
			_setup_trap_button(button_instance, trap_data)
			
			trap_container.add_child(button_instance)
	
	print("✅ Generated %d trap buttons" % traps_data.size())

func _setup_enemy_button(button: Button, enemy_data: Dictionary):
	# Gunakan enemy_type sebagai nama (format: Grease_Rat -> Grease Rat)
	var enemy_name = enemy_data.get("enemy_type", "").replace("_", " ")
	button.text = enemy_name
	for child in button.get_children():
		if child is Label:
			child.text = enemy_name
			break
	
	# Simpan data lengkap sebagai metadata
	button.set_meta("enemy_data", enemy_data)
	
	# Connect signal
	button.pressed.connect(_on_enemy_button_pressed.bind(button))

func _setup_tower_button(button: Button, tower_data: Dictionary):
	# Gunakan tower_type sebagai nama
	var tower_name = tower_data.get("tower_type", "").replace("_", " ")
	button.text = tower_name
	for child in button.get_children():
		if child is Label:
			child.text = tower_name
			break
	
	# Simpan data lengkap sebagai metadata
	button.set_meta("tower_data", tower_data)
	
	# Connect signal
	button.pressed.connect(_on_tower_button_pressed.bind(button))

func _setup_trap_button(button: Button, trap_data: Dictionary):
	# Gunakan trap_type sebagai nama
	var trap_name = trap_data.get("trap_type", "").replace("_", " ")
	button.text = trap_name
	
	# Simpan data lengkap sebagai metadata
	button.set_meta("trap_data", trap_data)
	
	# Connect signal
	button.pressed.connect(_on_trap_button_pressed.bind(button))

func _clear_container(container: Container):
	for child in container.get_children():
		child.queue_free()

func _on_enemy_button_pressed(button: Button):
	var enemy_data = button.get_meta("enemy_data", {})
	_show_enemy_detail(enemy_data)
	
	# Highlight button yang dipilih
	_reset_button_highlights(enemies_container)
	button.modulate = Color(1.1, 1.1, 0.9, 1.0)

func _on_tower_button_pressed(button: Button):
	var tower_data = button.get_meta("tower_data", {})
	_show_tower_detail(tower_data)
	
	# Highlight button yang dipilih
	_reset_button_highlights(tower_container)
	button.modulate = Color(1.1, 1.1, 0.9, 1.0)

func _on_trap_button_pressed(button: Button):
	var trap_data = button.get_meta("trap_data", {})
	_show_trap_detail(trap_data)
	
	# Highlight button yang dipilih
	_reset_button_highlights(trap_container)
	button.modulate = Color(1.1, 1.1, 0.9, 1.0)

func _show_enemy_detail(enemy_data: Dictionary):
	detail_panel.visible = true
	
	# Title
	var enemy_name = enemy_data.get("enemy_type", "").replace("_", " ")
	detail_title.text = enemy_name
	
	# Type
	var enemy_type = enemy_data.get("type", "Unknown Type")
	detail_type.text = "Type: " + enemy_type
	
	# Ability
	var enemy_ability = enemy_data.get("ability", "No ability")
	detail_ability.text = "Ability: " + enemy_ability
	
	# Image - ambil dari field "image_path" di CSV
	var image_path = enemy_data.get("image_path", "")
	_load_image_to_sprite(image_path)
	
	# Description
	var description = enemy_data.get("description", "No description available.")
	detail_description.text = description
	detail_description.scroll_active = false

func _show_tower_detail(tower_data: Dictionary):
	detail_panel.visible = true
	
	# Title
	var tower_name = tower_data.get("tower_type", "").replace("_", " ")
	detail_title.text = tower_name
	
	# Type
	var tower_type = tower_data.get("type", "Unknown Type")
	detail_type.text = "Type: " + tower_type
	
	# Ability
	var tower_ability = tower_data.get("ability", "No ability")
	detail_ability.text = "Ability: " + tower_ability
	
	# Image - ambil dari field "image_path" di CSV
	var image_path = tower_data.get("image_path", "")
	_load_image_to_sprite(image_path)
	
	# Description
	var description = tower_data.get("description", "No description available.")
	detail_description.text = description

func _show_trap_detail(trap_data: Dictionary):
	detail_panel.visible = true
	
	# Title
	var trap_name = trap_data.get("trap_type", "").replace("_", " ")
	detail_title.text = trap_name
	
	# Type
	var trap_type = trap_data.get("type", "Unknown Type")
	detail_type.text = "Type: " + trap_type
	
	# Ability
	var trap_ability = trap_data.get("ability", "No ability")
	detail_ability.text = "Ability: " + trap_ability
	
	# Image - ambil dari field "image_path" di CSV
	var image_path = trap_data.get("image_path", "")
	_load_image_to_sprite(image_path)
	
	# Description
	var description = trap_data.get("description", "No description available.")
	detail_description.text = description

func _load_image_to_sprite(image_path: String):
	# Reset texture terlebih dahulu
	detail_image.texture = null
	
	# Jika image_path kosong, gunakan placeholder
	if image_path == "":
		# Buat placeholder texture atau biarkan kosong
		print("⚠️ No image path specified")
		return
	
	# Coba load texture dari path
	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		if texture:
			detail_image.texture = texture
			print("✅ Loaded image: ", image_path)
		else:
			print("❌ Failed to load texture: ", image_path)
	else:
		print("❌ Image file not found: ", image_path)

func _reset_button_highlights(container: Container):
	for child in container.get_children():
		if child is Button:
			child.modulate = Color.WHITE

func _auto_select_first_enemy():
	if enemies_container.get_child_count() > 0:
		var first_button = enemies_container.get_child(0)
		if first_button is Button:
			await get_tree().process_frame
			first_button.emit_signal("pressed")

func _on_button_enemies_pressed() -> void:
	panel_enemies.visible = true
	panel_tower.visible = false
	panel_trap.visible = false
	
	if enemies_container.get_child_count() == 0:
		generate_enemy_buttons()
	
	if enemies_container.get_child_count() > 0:
		var first_button = enemies_container.get_child(0)
		if first_button is Button:
			await get_tree().create_timer(0.1).timeout
			first_button.emit_signal("pressed")

func _on_button_tower_pressed() -> void:
	panel_enemies.visible = false
	panel_tower.visible = true
	panel_trap.visible = false
	
	if tower_container.get_child_count() == 0:
		generate_tower_buttons()
	
	if tower_container.get_child_count() > 0:
		var first_button = tower_container.get_child(0)
		if first_button is Button:
			await get_tree().create_timer(0.1).timeout
			first_button.emit_signal("pressed")

func _on_button_trap_pressed() -> void:
	panel_enemies.visible = false
	panel_tower.visible = false
	panel_trap.visible = true
	
	if trap_container.get_child_count() == 0:
		generate_trap_buttons()
	
	if trap_container.get_child_count() > 0:
		var first_button = trap_container.get_child(0)
		if first_button is Button:
			await get_tree().create_timer(0.1).timeout
			first_button.emit_signal("pressed")

func _on_button_close_pressed() -> void:
	panel_encyclopedia.visible = false

#"res://asset/Grease_Rat.png"
#"res://asset/Sequirel_Fire.png"
#"res://asset/Monkey.png"
#"res://asset/Ice_Chiller.png"
#"res://asset/Stove_Cannon.png"
#"res://asset/Chilli_Launcher.png"
#"res://asset/Pepper_Grinder.png"
#"res://asset/Garlic_Barrier.png"
