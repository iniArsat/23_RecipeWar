extends TowerBase
class_name GarlicTower

var is_aura_active := false
var can_activate := true
var enemies_in_range: Array = []  # Menyimpan semua musuh dalam range
var currently_slowed_enemies: Array = []  # Menyimpan musuh yang sedang di-slow

# References
@onready var aura: Sprite2D = $Aura_Effect
@onready var slow_area: Area2D = $Sight
@onready var slow_collision: CollisionShape2D = $Sight/CollisionShape2D
@onready var range_visual: RangeVisual = $Range_Visual

@export var slow_effect_resource: StatusEffect

func _tower_specific_ready():
	aura.visible = false
	setup_range_collision()

	# Setup visual awal
	if range_visual:
		range_visual.visible = false
		range_visual.update_radius(range_radius)
		range_visual.color = Color(0.5, 0.0, 0.8, 0.2)  # Ungu untuk garlic
		range_visual.border_color = Color(0.5, 0.0, 0.8, 0.5)

func _tower_specific_update(delta: float):
	# Aktifkan aura jika ada musuh dan tidak sedang cooldown
	if can_activate and enemies_in_range.size() > 0:
		_activate_aura()
	
	_update_visuals()

func _tower_specific_setup_range():
	# Setup collision radius dari base class
	setup_range_collision()

func setup_range_collision():
	if slow_collision and slow_collision.shape is CircleShape2D:
		slow_collision.shape.radius = range_radius
	
	# Update visual range jika ada
	if range_visual:
		range_visual.update_radius(range_radius)

func _activate_aura():
	if not can_activate or is_aura_active:
		return
	
	can_activate = false
	is_aura_active = true
	aura.visible = true
	
	# Terapkan slow ke semua musuh dalam range
	_apply_slow_to_enemies_in_range()
	
	# Timer untuk durasi aura
	await get_tree().create_timer(slow_effect_resource.duration).timeout
	
	# Nonaktifkan aura
	is_aura_active = false
	aura.visible = false
	_remove_all_slows()
	can_activate = true

func _apply_slow_to_enemies_in_range():
	_cleanup_enemies()
	
	# Terapkan slow ke semua musuh yang ada di range
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("add_status_effect"):
			# Duplikasi resource untuk setiap enemy
			var effect = slow_effect_resource.duplicate()
			enemy.add_status_effect(effect)
			if not enemy in currently_slowed_enemies:
				currently_slowed_enemies.append(enemy)

func _remove_all_slows():
	# Hentikan slow efek untuk semua musuh
	for enemy in currently_slowed_enemies:
		if is_instance_valid(enemy) and enemy.has_method("remove_slow"):
			enemy.remove_slow()
	
	currently_slowed_enemies.clear()

func _update_visuals():
	if is_destroyed:
		# Sembunyikan semua visual jika tower hancur
		if range_visual:
			range_visual.visible = false
		if aura and aura.visible:
			aura.visible = false
		return
	
	# Update range visual berdasarkan state
	if range_visual:
		if is_aura_active:
			# Aura aktif - warna ungu terang
			if not range_visual.visible:
				range_visual.visible = true
			range_visual.color = Color(0.8, 0.0, 1.0, 0.3)  # Ungu terang transparan
			range_visual.border_color = Color(0.8, 0.0, 1.0, 0.7)
			range_visual.border_width = 3.0  # Border lebih tebal saat aktif
		elif enemies_in_range.size() > 0:
			# Ada musuh tapi aura belum aktif - warna ungu standar
			if not range_visual.visible:
				range_visual.visible = true
			range_visual.color = Color(0.5, 0.0, 0.8, 0.2)  # Ungu standar transparan
			range_visual.border_color = Color(0.5, 0.0, 0.8, 0.5)
			range_visual.border_width = 2.0  # Border normal
		else:
			# Tidak ada musuh - sembunyikan
			range_visual.visible = false
	
	# Update aura sprite visibility
	aura.visible = is_aura_active

func _cleanup_enemies():
	# Bersihkan arrays dari musuh yang tidak valid
	var valid_enemies = []
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)
		else:
			print("Garlic Tower: Removing invalid enemy from range list")
	enemies_in_range = valid_enemies
	
	var valid_slowed = []
	for enemy in currently_slowed_enemies:
		if is_instance_valid(enemy):
			valid_slowed.append(enemy)
		else:
			print("Garlic Tower: Removing invalid enemy from slowed list")
	currently_slowed_enemies = valid_slowed

func _on_slow_area_body_entered(body: Node2D):
	if body.is_in_group("player") and is_instance_valid(body):
		if not body in enemies_in_range:
			print("Garlic Tower: Enemy entered range - ", body.name)
			enemies_in_range.append(body)
		
		# Jika aura sedang aktif, langsung slow musuh yang baru masuk
		if is_aura_active and body.has_method("add_status_effect"):
			print("Garlic Tower: Immediately slowing new enemy - ", body.name)
			var effect = slow_effect_resource.duplicate()
			body.add_status_effect(effect)
			if not body in currently_slowed_enemies:
				currently_slowed_enemies.append(body)

func _on_slow_area_body_exited(body: Node2D):
	if body.is_in_group("player"):
		if body in enemies_in_range:
			print("Garlic Tower: Enemy exited range - ", body.name)
			enemies_in_range.erase(body)
		
		# Hentikan slow jika musuh keluar dari range
		if body in currently_slowed_enemies:
			if is_instance_valid(body) and body.has_method("remove_status_effect_by_name"):
				print("Garlic Tower: Removing slow from exiting enemy - ", body.name)
				body.remove_status_effect_by_name("SLOW")
			currently_slowed_enemies.erase(body)

func _disable_attacks(duration: float):
	# Nonaktifkan aura dan skill untuk durasi tertentu
	print("Garlic Tower: Disabling attacks for ", duration, " seconds")
	
	# Hentikan aura jika sedang aktif
	if is_aura_active:
		is_aura_active = false
		aura.visible = false
		_remove_all_slows()
	
	# Nonaktifkan aktivasi
	can_activate = false
	
	# Timer untuk mengaktifkan kembali
	await get_tree().create_timer(duration).timeout
	
	can_activate = true
	print(" Garlic Tower: Attacks re-enabled")

# Override untuk upgrade stats spesifik Garlic Tower
func apply_upgrade_stats():
	if upgrade_level <= 3:
		var stat_index = upgrade_level - 1
		
		# Apply base stats dari array
		if stat_index < damage_stats.size():
			# Untuk garlic, damage stats bisa digunakan untuk slow power
			slow_effect_resource.power = min(0.95, damage_stats[stat_index] * 0.1)  # Convert to 0-1 range, max 95%
		if stat_index < cooldown_stats.size():
			cooldown = cooldown_stats[stat_index]
		if stat_index < range_stats.size():
			range_radius = range_stats[stat_index]
			setup_range_collision()  # Update collision
			
			# Update visual range
			if range_visual:
				range_visual.update_radius(range_radius)
				range_visual.queue_redraw()
	
	# Update head texture jika ada
	_update_head_texture()
	
	print(" Garlic Tower: Upgraded to level ", upgrade_level)
	print("  - Cooldown: ", cooldown, "s")
	print("  - Range: ", range_radius)

# Override setup_from_data untuk garlic-specific stats
func setup_from_data(tower_type: String, data: Dictionary):
	# Panggil parent method terlebih dahulu
	super.setup_from_data(tower_type, data)
	
	# Setup stats dari CSV
	slow_effect_resource.duration = data.get("slow_duration", 5.0)
	
	# Setup damage stats untuk upgrade
	self.damage_stats = [
		data.get("damage_level1", 5.0),
		data.get("damage_level2", 6.0),
		data.get("damage_level3", 8.0)
	]
	
	# Setup range stats untuk upgrade (INI YANG PENTING!)
	self.range_stats = [
		data.get("range_level1", 150.0),
		data.get("range_level2", 175.0),
		data.get("range_level3", 200.0)
	]
	
	# Set initial range radius dari level 1
	range_radius = data.get("range_level1", 150.0)
	
	# Set initial slow power dari CSV
	var initial_slow_power = data.get("slow_power", 0.5)
	slow_effect_resource.power = initial_slow_power
	
	# Setup range collision dan visual SETELAH range_radius diatur
	call_deferred("setup_range_collision")
	if range_visual:
		call_deferred("_update_visuals")

# Override untuk destruction
func _destroy_tower():
	super._destroy_tower()
	
	# Garlic-specific: Hentikan semua slow efek
	_remove_all_slows()
	
	# Reset state
	is_aura_active = false
	aura.visible = false
	can_activate = false
	
	# Sembunyikan range visual
	if range_visual:
		range_visual.visible = false

# Override untuk repair
func _repair_tower():
	super._repair_tower()
	
	# Reset garlic-specific state
	can_activate = true
	is_aura_active = false
	aura.visible = false

# Override untuk get_stats dengan info tambahan
func get_stats() -> Dictionary:
	var base_stats = super.get_stats()
	base_stats["slow_power"] = str(int(slow_effect_resource.power * 100)) + "%"
	base_stats["slow_duration"] = str(slow_effect_resource.duration) + "s"
	base_stats["aura_active"] = is_aura_active
	base_stats["enemies_in_range"] = enemies_in_range.size()
	base_stats["can_activate"] = can_activate
	return base_stats

# Fungsi untuk mengubah warna range visual
func set_range_visual_color(fill_color: Color, border_color: Color, border_width: float = 2.0):
	if range_visual:
		range_visual.color = fill_color
		range_visual.border_color = border_color
		range_visual.border_width = border_width
		range_visual.queue_redraw()

# Fungsi untuk toggle range visual (debug/testing)
func toggle_range_visual():
	if range_visual:
		range_visual.visible = !range_visual.visible
