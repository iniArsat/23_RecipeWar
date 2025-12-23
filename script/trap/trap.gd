extends Node2D

# Variables yang akan di-set dari CSV
var trap_type: String = "Chili_Bomb_Trap"
var damage: float = 50.0
var radius: float = 150.0
var cooldown: float = 10.0
var base_cost: int = 75
var effect_duration: float = 2.0
var effect_type: String = "burn"  # "burn", "stun", "slow"

var knockback_force: float = 10.0
var bounce_count: int = 1
var bounce_interval: float = 0.3
var knockback_distance: float = 60.0

# References
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var range_visual: Node2D = $Range_Visual

var is_armed := true
var is_active := false
var activation_timer := 0.0
var enemies_hit: Array = []  # Untuk mencegah multiple hits ke enemy yang sama

var is_dragging = false
@onready var panel_upgrade: Panel = $Panel

func _ready():
	panel_upgrade.visible = false
	if range_visual:
		range_visual.visible = false
		update_range_visual_scale()
	
	ClickManager.connect("screen_clicked", Callable(self, "_on_screen_clicked"))
	setup_area_collision()
	
	# Debug
	print("🛠️ Trap loaded: ", trap_type, " | Damage: ", damage, " | Radius: ", radius)

func _process(delta: float) -> void:
	if is_dragging:
		return
	
	if is_active:
		activation_timer -= delta
		
		# Cek musuh di area saat trap aktif
		_check_enemies_in_area()
		
		if activation_timer <= 0:
			# Hancurkan trap setelah selesai
			_destroy_trap()

func setup_area_collision():
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = radius

func update_range_visual_scale():
	if range_visual:
		range_visual.update_radius(radius)

func _on_area_body_entered(body: Node2D) -> void:
	# Debug
	print("📥 Trap area entered by: ", body.name, " | Is player: ", body.is_in_group("player"))
	
	if body.is_in_group("player") and is_armed and not is_active:
		print("🎯 Enemy detected! Activating trap...")
		_activate_trap()

func _activate_trap():
	print("💥 TRAP ACTIVATED: ", trap_type, " at position: ", global_position)
	
	is_armed = false
	is_active = true
	activation_timer = 0.5  # Trap aktif selama 0.5 detik untuk memberikan damage
	enemies_hit.clear()     # Reset daftar musuh yang sudah kena
	
	# Visual feedback
	$Sprite2D.modulate = Color.RED
	
	# Show range visual
	if range_visual:
		range_visual.visible = true
	
	# Trigger effect INSTANTLY pada semua musuh dalam radius
	_apply_instant_effect()
	
	# Play sound effect (optional)
	# $ActivationSound.play()

func _apply_instant_effect():
	print("⚡ Applying instant effect to enemies in radius...")
	
	# Cari semua musuh dalam radius
	var all_enemies = get_tree().get_nodes_in_group("player")
	var hit_count = 0
	
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy not in enemies_hit:
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= radius:
				print("🎯 Enemy in range: ", enemy.name, " | Distance: ", distance)
				_apply_trap_effect(enemy)
				enemies_hit.append(enemy)
				hit_count += 1
	
	print("✅ Trap hit ", hit_count, " enemies")

func _apply_trap_effect(enemy: Node2D):
	if not is_instance_valid(enemy):
		return
	
	print("🎯 Applying ", effect_type, " effect to enemy")
	
	match effect_type:
		"burn":
			# Damage instan + efek burn
			if enemy.has_method("take_damage"):
				print("💥 Direct damage: ", int(damage))
				enemy.take_damage(int(damage))
			
			if enemy.has_method("apply_burn"):
				print("🔥 Applying burn for ", effect_duration, " seconds")
				enemy.apply_burn(effect_duration)
		
		"stun":
			# Efek stun saja (tanpa damage)
			if enemy.has_method("apply_stun"):
				print("😵 Applying stun for ", effect_duration, " seconds")
				enemy.apply_stun(effect_duration)
		
		"slow":
			# Efek slow saja (tanpa damage)
			if enemy.has_method("apply_slow"):
				print("🐌 Applying slow for ", effect_duration, " seconds")
				enemy.apply_slow(0.5, effect_duration)  # 50% slow
				
		"knockback":  # TAMBAH CASE INI
			_apply_knockback_effect(enemy)

func _apply_knockback_effect(enemy: Node2D):
	print("🔄 Applying PATH knockback")
	
	# Damage awal
	if enemy.has_method("take_damage"):
		enemy.take_damage(int(damage))
	
	# Bounce sequence mundur di path
	for i in range(bounce_count):
		var delay = i * bounce_interval
		await get_tree().create_timer(delay).timeout
		
		if is_instance_valid(enemy) and enemy.has_method("apply_path_knockback"):
			# Hitung jarak mundur per bounce
			var bounce_distances = [80.0, 50.0, 30.0]  # Progress units
			enemy.apply_path_knockback(knockback_distance)
			
			# Damage kecil per bounce
			if enemy.has_method("take_damage"):
				enemy.take_damage(int(damage * 0.2))

func _create_bounce_popup(position: Vector2, num: int):
	# Simple text effect
	var label = Label.new()
	label.text = "Bounce!"
	label.position = position + Vector2(-15, -20 - (num * 5))
	label.add_theme_font_size_override("font_size", 12 + num * 2)
	
	get_tree().current_scene.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.4)
	tween.finished.connect(label.queue_free)
		
func _check_enemies_in_area():
	# Untuk memastikan tidak ada musuh yang terlewat
	var all_enemies = get_tree().get_nodes_in_group("player")
	
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy not in enemies_hit:
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= radius:
				print("🎯 Additional enemy in range: ", enemy.name)
				_apply_trap_effect(enemy)
				enemies_hit.append(enemy)

func _destroy_trap():
	
	# Visual effect sebelum dihancurkan
	$Sprite2D.modulate = Color(1, 1, 1, 0.5)  # Fade out
	
	# Hapus dari daftar trap yang terpasang
	if self in GameManager.placed_traps:
		GameManager.placed_traps.erase(self)
	
	# Delay sedikit sebelum dihancurkan untuk efek visual
	await get_tree().create_timer(0.3).timeout
	
	# Hancurkan trap
	queue_free()

# Drag & Drop system
func start_drag():
	is_dragging = true
	process_mode = Node.PROCESS_MODE_DISABLED
	if range_visual:
		range_visual.visible = true

func stop_drag():
	is_dragging = false
	process_mode = Node.PROCESS_MODE_INHERIT
	if range_visual:
		range_visual.visible = false

func setup_from_data(trap_type: String, data: Dictionary):
	self.trap_type = trap_type
	self.damage = data.get("damage", 50.0)
	self.radius = data.get("radius", 150.0)
	self.cooldown = data.get("cooldown", 10.0)
	self.base_cost = data.get("base_cost", 75)
	self.effect_duration = data.get("effect_duration", 2.0)
	self.effect_type = data.get("effect_type", "burn")
	
	if trap_type == "Gelatin_Bounce_Trap":
		self.knockback_force = 10.0
		self.bounce_count = 1
		self.bounce_interval = 0.3
	
	call_deferred("setup_area_collision")
	call_deferred("update_range_visual_scale")

func get_base_cost() -> int:
	return base_cost

func _on_shape_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var main_scene = get_tree().get_root().get_node("Main")
		if main_scene and main_scene.has_method("show_trap_info"):
			main_scene.show_trap_info(self)

func _on_screen_clicked(pos: Vector2) -> void:
	if panel_upgrade.visible:
		var panel_rect = panel_upgrade.get_global_rect()
		if not panel_rect.has_point(pos):
			panel_upgrade.visible = false
