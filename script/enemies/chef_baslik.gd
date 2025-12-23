extends BaseEnemy

# ====== EXPORT VARIABLES ======
@export var bullet_clear_radius := 150.0  # 0 = no skill
@export var skill_cooldown := 15.0
@export var skill_duration := 5.0
@export var trigger_health_percentage := 75.0
@export var use_separate_skill_manager := false

# Variabel jika menggunakan skill manager terpisah
@export var boss_skill_manager: BossSkillManager

# ====== INITIALIZATION ======
func _setup_additional():
	super._setup_additional()
	
	if use_separate_skill_manager and boss_skill_manager:
		# Gunakan BossSkillManager yang sudah di-set di Inspector
		boss_skill_manager.set_enemy(self)
		boss_skill_manager.bullet_clear_radius = bullet_clear_radius
		boss_skill_manager.skill_cooldown = skill_cooldown
		boss_skill_manager.skill_duration = skill_duration
		boss_skill_manager.trigger_health_percentage = trigger_health_percentage
	elif bullet_clear_radius > 0:
		# Buat BossSkillManager internal (embedded)
		boss_skill_manager = BossSkillManager.new(self)
		boss_skill_manager.bullet_clear_radius = bullet_clear_radius
		boss_skill_manager.skill_cooldown = skill_cooldown
		boss_skill_manager.skill_duration = skill_duration
		boss_skill_manager.trigger_health_percentage = trigger_health_percentage

# ====== PROCESS UPDATES ======
func _additional_process(delta: float):
	if boss_skill_manager:
		boss_skill_manager.update(delta)

# ====== DRAWING ======
func _additional_draw():
	if boss_skill_manager and boss_skill_manager.is_skill_active:
		_draw_skill_area()

func _draw_skill_area():
	var radius = bullet_clear_radius
	
	# Draw filled circle
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.0, 1.0, 0.3))
	
	# Draw border
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1.0, 0.5, 1.0, 0.7), 3.0)
	
	# Draw pulsating effect
	var pulse = abs(sin(Time.get_ticks_msec() * 0.005)) * 0.2 + 0.8
	var pulse_color = Color(1.0, 0.5, 1.0, pulse)
	draw_arc(Vector2.ZERO, radius + 5, 0, TAU, 32, pulse_color, 1.0)

# ====== DAMAGE HANDLING ======
func _on_damage_taken(amount: int, current_hp: float):
	if boss_skill_manager:
		var health_percentage = (current_hp / health) * 100
		boss_skill_manager.trigger_skill_by_health(health_percentage)

# ====== SPECIAL BLIND CHECK ======
func _is_special_blinded() -> bool:
	return boss_skill_manager and boss_skill_manager.is_skill_active
