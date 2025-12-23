extends Node2D
class_name BaseEnemy

# ====== EXPORT VARIABLES ======
# Basic stats
@export var health := 0.0
@export var speed := 0.0
@export var coin_reward := 0.0
@export var dps_damage := 0.0

# Tower attack stats
@export var can_attack_towers := false
@export var tower_damage := 0.0 
@export var tower_attack_range := 120.0
@export var tower_attack_cooldown := 5.0
@export var enemy_bullet_scene: PackedScene

# Nerf effects
@export var nerf_type: String = ""
@export var nerf_power: float = 0.0
@export var nerf_duration: float = 3.0
@export var nerf_effect_resource: NerfEffect

# ====== INTERNAL VARIABLES ======
var current_health := 0.0
var knockback_progress_loss := 0.0
var is_knocked_back = false

# UI references
@onready var health_bar: ProgressBar = $HealthBar
@onready var status_label: Label = $StatusLabel
@onready var status_miss_label: Label = $StatusMiss

# Timers
var hide_timer := 0.0
var hide_delay := 2.0
var dps_timer := 0.0
var dps_interval := 1.0
var tower_attack_timer := 0.0

# State flags
var reached_end := false
var is_attacking_base := false
var original_speed := 0.0

# Tower targeting
var current_target_tower: Node = null
var towers_in_range: Array = []

# Miss counter
var miss_count: int = 0

# Status effects
var active_effects: Array[StatusEffect] = []

# ====== READY & INITIALIZATION ======
func _ready():
	call_deferred("apply_csv_values")

func apply_csv_values():
	current_health = health
	original_speed = speed
	
	_setup_ui()
	_setup_additional()

# Virtual methods untuk di-override oleh child classes
func _setup_ui():
	if health_bar:
		health_bar.max_value = health
		health_bar.value = current_health
		health_bar.visible = false
	
	if status_label:
		status_label.visible = false
	
	if status_miss_label:
		status_miss_label.visible = false
		status_miss_label.text = "MISS: 0"

func _setup_additional():
	pass  # Di-override oleh child classes

# ====== PROCESS & UPDATES ======
func _process(delta: float) -> void:
	_update_movement(delta)
	_update_status_effects(delta)
	_update_combat(delta)
	_update_ui(delta)
	_additional_process(delta)  # Untuk child classes
	
	queue_redraw()

func _update_movement(delta: float) -> void:
	if not reached_end and not is_knocked_back:
		get_parent().set_progress(get_parent().get_progress() + speed * delta)
		health_bar.rotation = 0
		
		if get_parent().get_progress_ratio() >= 0.99:
			_reach_base()

func _update_status_effects(delta: float) -> void:
	for effect in active_effects:
		effect.update(self, delta)
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		if effect.is_finished():
			effect.remove(self)
			active_effects.remove_at(i)

func _update_combat(delta: float) -> void:
	if is_attacking_base:
		_update_base_attack(delta)
	
	if can_attack_towers:
		_update_tower_attack(delta)

func _update_ui(delta: float) -> void:
	if health_bar.visible:
		hide_timer -= delta
		if hide_timer <= 0:
			health_bar.visible = false

func _additional_process(delta: float):
	pass  # Di-override oleh child classes

# ====== DRAWING ======
func _draw():
	_additional_draw()  # Untuk child classes

func _additional_draw():
	pass  # Di-override oleh child classes

# ====== COMBAT LOGIC ======
func _update_base_attack(delta: float) -> void:
	dps_timer -= delta
	if dps_timer <= 0:
		_attack_base()
		dps_timer = dps_interval

func _update_tower_attack(delta: float) -> void:
	tower_attack_timer -= delta
	_find_tower_targets()
	
	if current_target_tower and tower_attack_timer <= 0 and not is_blinded():
		_attack_tower()
		tower_attack_timer = tower_attack_cooldown

func _find_tower_targets():
	if is_blinded():
		towers_in_range.clear()
		current_target_tower = null
		return
	
	# Filter valid towers
	towers_in_range = towers_in_range.filter(func(tower): return is_instance_valid(tower))
	
	# Find towers in range
	var all_towers = get_tree().get_nodes_in_group("tower")
	for tower in all_towers:
		if _is_valid_tower_target(tower):
			if not tower in towers_in_range:
				towers_in_range.append(tower)
	
	# Remove invalid towers
	for i in range(towers_in_range.size() - 1, -1, -1):
		var tower = towers_in_range[i]
		if not _is_valid_tower_target(tower):
			towers_in_range.remove_at(i)
	
	# Select target
	if towers_in_range.size() > 0:
		if not current_target_tower or not current_target_tower in towers_in_range:
			current_target_tower = towers_in_range[0]
	else:
		current_target_tower = null

func _is_valid_tower_target(tower: Node) -> bool:
	return (is_instance_valid(tower) and 
			global_position.distance_to(tower.global_position) <= tower_attack_range and
			not tower.is_in_group("ignore_damage") and
			not tower.is_in_group("repair_tower"))

func _attack_tower():
	if not current_target_tower or not enemy_bullet_scene:
		return
	
	# Create bullet
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.target = current_target_tower
	
	# Setup nerf effects
	if nerf_effect_resource:
		bullet.nerf_effect_resource = nerf_effect_resource.duplicate()
	else:
		# Fallback to old system
		bullet.nerf_type = nerf_type
		bullet.nerf_power = nerf_power
		bullet.nerf_duration = nerf_duration
	
	bullet.tower_damage = tower_damage 
	get_tree().current_scene.add_child(bullet)

func _attack_base() -> void:
	GameManager._take_damage(dps_damage)

func _reach_base() -> void:
	reached_end = true
	is_attacking_base = true
	dps_timer = dps_interval

# ====== DAMAGE & EFFECTS ======
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	
	health_bar.value = current_health
	health_bar.visible = true
	hide_timer = hide_delay
	
	_on_damage_taken(amount, current_health)  # Callback untuk child classes
	
	if current_health <= 0:
		die()

func _on_damage_taken(amount: int, current_hp: float):
	pass  # Di-override oleh child classes

func apply_path_knockback(distance_back: float):
	is_knocked_back = true
	var path_parent = get_parent() as PathFollow2D
	
	if path_parent:
		print("🎯 Knockback: moving back ", distance_back, " progress units")
		path_parent.progress = max(path_parent.progress - distance_back, 0.0)
		
		_show_status("KNOCKBACK!", Color(0.9, 0.3, 0.9))
		
		# Squeeze effect
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.4, 0.6), 0.15)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		
		await get_tree().create_timer(0.5).timeout
		is_knocked_back = false

func add_miss():
	miss_count += 1
	
	if status_miss_label:
		status_miss_label.text = "MISS: " + str(miss_count)
		status_miss_label.visible = true
		
		get_tree().create_timer(0.5).timeout.connect(_hide_miss_label)
	
	print("🎯 MISS counter: ", miss_count)

func _hide_miss_label():
	if status_miss_label:
		status_miss_label.visible = false
	miss_count = 0

func reset_miss():
	miss_count = 0
	if status_miss_label:
		status_miss_label.visible = false
		status_miss_label.text = "MISS: 0"

# ====== STATUS EFFECT SYSTEM ======
func add_status_effect(effect_resource: StatusEffect):
	for i in range(active_effects.size()):
		var active_effect = active_effects[i]
		if active_effect.effect_name == effect_resource.effect_name:
			active_effect.remove(self)
			var new_effect = effect_resource.duplicate()
			active_effects[i] = new_effect
			new_effect.apply(self)
			return
	var new_effect = effect_resource.duplicate()
	active_effects.append(new_effect)
	new_effect.apply(self)

func remove_status_effect(effect: StatusEffect):
	if effect in active_effects:
		effect.remove(self)
		active_effects.erase(effect)

#func remove_status_effect_by_name(effect_name: String):
	#for i in range(active_effects.size() - 1, -1, -1):
		#var effect = active_effects[i]
		#if effect.effect_name == effect_name:
			#effect.remove(self)
			#active_effects.remove_at(i)
			#return

func has_status_effect(effect_name: String) -> bool:
	for effect in active_effects:
		if effect.effect_name == effect_name:
			return true
	return false

func is_blinded() -> bool:
	return has_status_effect("BLIND") or _is_special_blinded()  # Di-override untuk skill khusus

func _is_special_blinded() -> bool:
	return false  # Di-override oleh child classes

# ====== UI METHODS ======
func _show_status(text: String, color: Color):
	if status_label:
		status_label.text = text
		status_label.modulate = color
		status_label.visible = true
		
		## Auto-hide after delay
		#get_tree().create_timer(1.0).timeout.connect(_hide_status)

func _hide_status():
	if status_label:
		status_label.visible = false

# ====== CLEANUP ======
func die() -> void:
	_before_die()  # Callback sebelum mati
	GameManager._add_coin(coin_reward)
	queue_free()

func _before_die():
	pass  # Di-override oleh child classes
