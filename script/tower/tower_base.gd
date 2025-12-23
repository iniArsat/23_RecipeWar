extends Node2D
class_name TowerBase

# SIGNAL YANG UMUM
signal tower_clicked(tower_instance)
signal tower_upgraded(new_level)
signal tower_destroyed()
signal tower_repaired()

# VARIABEL INTI YANG DIMILIKI SEMUA TOWER
@export_category("Tower Properties")
@export var tower_type: String = "Base_Tower"
@export var max_health := 100.0
@export var base_cost: int = 100

@export_category("Attack Properties")
@export var bullet_speed := 250.0
@export var bullet_damage := 5.0
@export var cooldown := 1.0
@export var range_radius := 150.0
@export var trigger_radius := 0.0  # Hanya untuk tower tertentu

@export_category("Upgrade Properties")
@export var upgrade_cost_level2 := 50
@export var upgrade_cost_level3 := 100
@export var head_texture_level1: Texture2D
@export var head_texture_level2: Texture2D
@export var head_texture_level3: Texture2D

# STATS ARRAYS UNTUK UPGRADE
var damage_stats: Array = [5.0, 6.0, 8.0]
var cooldown_stats: Array = [1.5, 1.3, 1.0]
var range_stats: Array = [90.0, 100.0, 110.0]

# SISTEM HEALTH & REPAIR
var current_health := 0.0
var is_destroyed := false
var repair_progress := 0.0
var hide_health_timer := 0.0
var hide_health_delay := 2.0
@onready var health_bar: ProgressBar = $HealthBar
@onready var repair_label: Label = $RepairLabel
@onready var status_label: Label = $StatusEfek
@export var original_accuracy: float = 1.0

# SISTEM UPGRADE
var upgrade_level := 1

## SISTEM NERF
#var active_nerfs: Dictionary = {}
#var original_cooldown: float
#var original_accuracy: float = 1.0
var active_nerfs: Array[NerfEffect] = []
# SISTEM DRAG & DROP
var is_dragging := false

func _tower_specific_attack():
	pass
	
func _tower_specific_update(delta: float):
	pass

func _tower_specific_ready():
	pass

func _tower_specific_setup_range():
	pass

# COMMON READY FUNCTION
func _ready():
	_setup_common_properties()
	_tower_specific_ready()
	
func _setup_common_properties():
	current_health = max_health
	repair_progress = max_health
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.visible = false
	if repair_label:
		repair_label.visible = false
	if status_label:
		status_label.visible = false

# COMMON PROCESS FUNCTION
func _process(delta: float):
	if is_dragging:
		return
		
	if is_destroyed:
		_process_repair(delta)
		return
	
	_update_health_bar_timer(delta)
	_tower_specific_update(delta)
	_update_nerfs(delta)

# FUNGSI HEALTH BAR YANG HILANG
func _update_health_bar_timer(delta: float):
	if health_bar and health_bar.visible:
		hide_health_timer -= delta
		if hide_health_timer <= 0:
			health_bar.visible = false

# COMMON FUNCTIONS - YANG SAMA UNTUK SEMUA TOWER
func take_damage(damage: float):
	print("🛡️ Tower taking damage: ", damage, " (Current HP: ", current_health, ")")
	if is_destroyed:
		return
	
	current_health -= damage
	current_health = max(current_health, 0)
	
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = true
		hide_health_timer = hide_health_delay
	
	if current_health <= 0:
		_destroy_tower()

func _destroy_tower():
	is_destroyed = true
	repair_progress = 0.0
	current_health = 0
	_hide_nerf_status()
	
	add_to_group("repair_tower")
	tower_destroyed.emit()

func _process_repair(delta: float):
	repair_progress += 10.0 * delta
	current_health = min(repair_progress, max_health)
	
	if health_bar:
		health_bar.value = current_health
	
	if repair_label:
		var progress_percent = int((current_health / max_health) * 100)
		repair_label.text = "Repair: " + str(progress_percent) + "%"
		repair_label.visible = true
	
	if current_health >= max_health:
		_repair_tower()

func _repair_tower():
	is_destroyed = false
	current_health = max_health
	repair_progress = max_health
	
	remove_from_group("repair_tower")
	
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = true
		hide_health_timer = hide_health_delay
	
	if repair_label:
		repair_label.visible = false
	_hide_nerf_status()
	
	tower_repaired.emit()

# SISTEM UPGRADE YANG TERSTANDARDISASI
func upgrade_tower() -> bool:
	var upgrade_cost = get_upgrade_cost()
	
	if GameManager.coin < upgrade_cost:
		return false
	
	GameManager.coin -= upgrade_cost
	GameManager.update_coin.emit(GameManager.coin)
	
	upgrade_level += 1
	_apply_upgrade_stats()
	
	tower_upgraded.emit(upgrade_level)
	return true

func get_upgrade_cost() -> int:
	match upgrade_level:
		1: return upgrade_cost_level2
		2: return upgrade_cost_level3
		_: return 99999

func _apply_upgrade_stats():
	if upgrade_level <= 3:
		var stat_index = upgrade_level - 1
		
		if stat_index < damage_stats.size():
			bullet_damage = damage_stats[stat_index]
		if stat_index < cooldown_stats.size():
			cooldown = cooldown_stats[stat_index]
		if stat_index < range_stats.size():
			range_radius = range_stats[stat_index]
	
	_update_head_texture()
	#update_range_visual()
	_tower_specific_setup_range()

func apply_nerf_resource(nerf_resource: NerfEffect) -> void:
	# Cek jika nerf sudah aktif
	for nerf in active_nerfs:
		if nerf.nerf_name == nerf_resource.nerf_name:
			# Reset nerf yang sudah ada
			nerf.remove(self)
			var new_nerf = nerf_resource.duplicate()
			var index = active_nerfs.find(nerf)
			active_nerfs[index] = new_nerf
			new_nerf.apply(self)
			return
	
	# Jika nerf belum ada, tambahkan baru
	var new_nerf = nerf_resource.duplicate()
	active_nerfs.append(new_nerf)
	new_nerf.apply(self)

# UPDATE fungsi _update_nerfs
func _update_nerfs(delta: float):
	for i in range(active_nerfs.size() - 1, -1, -1):
		var nerf = active_nerfs[i]
		nerf.update(self, delta)
		
		# Hapus nerf yang sudah selesai
		if nerf.is_finished():
			nerf.remove(self)
			active_nerfs.remove_at(i)

func remove_nerf_by_name(nerf_name: String):
	for i in range(active_nerfs.size() - 1, -1, -1):
		var nerf = active_nerfs[i]
		if nerf.nerf_name == nerf_name:
			nerf.remove(self)
			active_nerfs.remove_at(i)
			
func _update_head_texture():
	var head = get_node_or_null("Head")
	if not head:
		return
		
	match upgrade_level:
		1: 
			if head_texture_level1: 
				head.texture = head_texture_level1
		2: 
			if head_texture_level2: 
				head.texture = head_texture_level2
		3: 
			if head_texture_level3: 
				head.texture = head_texture_level3

func update_range_visual():
	var range_visual = get_node_or_null("Range_Visual")
	if range_visual and range_visual.has_method("update_radius"):
		range_visual.update_radius(range_radius)

func _apply_mirror_damage(damage_percent: float, duration: float):
	var mirror_damage = max_health * damage_percent
	take_damage(mirror_damage)
	_disable_attacks(duration)

func _disable_attacks(duration: float):
	# Abstract method - implement di child
	pass

# DRAG & DROP SYSTEM
func start_drag():
	is_dragging = true
	process_mode = Node.PROCESS_MODE_DISABLED
	add_to_group("ignore_damage")

func stop_drag():
	is_dragging = false
	process_mode = Node.PROCESS_MODE_INHERIT
	remove_from_group("ignore_damage")

func get_stat_from_csv(stat_type: String, level: int) -> float:
	# Pastikan level valid (1-3)
	var level_index = level - 1
	if level_index < 0 or level_index > 2:
		return 0.0
	
	match stat_type:
		"damage":
			if level_index < damage_stats.size():
				return damage_stats[level_index]
		"range":
			if level_index < range_stats.size():
				return range_stats[level_index]
		"cooldown":
			if level_index < cooldown_stats.size():
				return cooldown_stats[level_index]
		_:
			return 0.0
	
	return 0.0

# Ambil stat saat ini dari CSV
func get_current_stat_from_csv(stat_type: String) -> float:
	return get_stat_from_csv(stat_type, upgrade_level)

# Ambil stat untuk level berikutnya dari CSV
func get_next_stat_from_csv(stat_type: String) -> float:
	if upgrade_level < 3:
		return get_stat_from_csv(stat_type, upgrade_level + 1)
	else:
		return get_stat_from_csv(stat_type, upgrade_level)
	
# SETUP DARI CSV DATA
func setup_from_data(tower_type: String, data: Dictionary):
	self.tower_type = tower_type
	self.bullet_speed = data.get("bullet_speed", bullet_speed)
	
	# Set stat arrays
	self.damage_stats = [
		data.get("damage_level1", damage_stats[0]),
		data.get("damage_level2", damage_stats[1]),
		data.get("damage_level3", damage_stats[2])
	]
	
	self.cooldown_stats = [
		data.get("cooldown_level1", cooldown_stats[0]),
		data.get("cooldown_level2", cooldown_stats[1]),
		data.get("cooldown_level3", cooldown_stats[2])
	]
	
	self.range_stats = [
		data.get("range_level1", range_stats[0]),
		data.get("range_level2", range_stats[1]),
		data.get("range_level3", range_stats[2])
	]
	
	# Set current stats (level 1)
	self.bullet_damage = damage_stats[0]
	self.cooldown = cooldown_stats[0]
	self.range_radius = range_stats[0]
	
	# Costs
	self.base_cost = data.get("base_cost", base_cost)
	self.upgrade_cost_level2 = data.get("upgrade_cost_level2", upgrade_cost_level2)
	self.upgrade_cost_level3 = data.get("upgrade_cost_level3", upgrade_cost_level3)
	
	# Setup collision
	call_deferred("_setup_collision")

func _setup_collision():
	var sight = get_node_or_null("Sight")
	if sight:
		var collision = sight.get_node_or_null("CollisionShape2D")
		if collision and collision.shape is CircleShape2D:
			collision.shape.radius = range_radius

func _show_nerf_status(text: String, color: Color = Color.RED):
	if status_label:
		status_label.text = text
		status_label.modulate = color
		status_label.visible = true
		status_label.modulate.a = 1.0

func _hide_nerf_status():
	if status_label:
		status_label.visible = false
		
# CLICK HANDLING
func _on_screen_clicked(pos: Vector2):
	var panel = get_node_or_null("Panel")
	if panel and panel.visible:
		var panel_rect = panel.get_global_rect()
		if not panel_rect.has_point(pos):
			panel.visible = false

func _on_shape_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tower_clicked.emit(self)
		
		# Juga kirim ke main scene jika ada
		var main_scene = get_tree().get_root().get_node("Main")
		if main_scene and main_scene.has_method("show_tower_info"):
			main_scene.show_tower_info(self)

# GETTER FUNCTIONS
func get_base_cost() -> int:
	return base_cost

func get_tower_damage() -> float:
	return bullet_damage

func get_tower_range() -> float:
	return range_radius

func get_tower_cooldown() -> float:
	return cooldown

func get_tower_upgrade_level() -> int:
	return upgrade_level

func get_stats() -> Dictionary:
	return {
		"type": tower_type,
		"damage": bullet_damage,
		"range": range_radius,
		"cooldown": cooldown,
		"level": upgrade_level,
		"health": str(int(current_health)) + "/" + str(int(max_health))
	}
