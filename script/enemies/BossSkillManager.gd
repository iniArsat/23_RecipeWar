class_name BossSkillManager
extends Node

# ====== EXPORT VARIABLES ======
@export var bullet_clear_radius := 100.0
@export var skill_cooldown := 10.0
@export var skill_duration := 4.0
@export var trigger_health_percentage := 75.0

# ====== INTERNAL VARIABLES ======
var enemy: Node2D
var skill_timer := 0.0
var is_skill_active := false
var current_skill_duration := 0.0

# ====== SIGNALS ======
signal skill_activated
signal skill_deactivated

# ====== FUNCTIONS ======
func _init(enemy_node: Node2D = null):
	if enemy_node:
		set_enemy(enemy_node)

func set_enemy(enemy_node: Node2D):
	enemy = enemy_node

func update(delta: float) -> void:
	if skill_timer > 0 and not is_skill_active:
		skill_timer -= delta
		if skill_timer <= 0:
			activate_skill()
	
	if is_skill_active:
		current_skill_duration -= delta
		if current_skill_duration <= 0:
			deactivate_skill()
		
		_destroy_bullets_in_range()

func activate_skill() -> void:
	print("🔥 BOSS menggunakan skill: BULLET CLEAR!")
	is_skill_active = true
	current_skill_duration = skill_duration
	
	# Clear initial bullets
	_clear_bullets_in_area()
	
	emit_signal("skill_activated")
	
	if enemy and enemy.has_method("_show_status"):
		enemy._show_status("BULLET CLEAR!", Color.MAGENTA)

func deactivate_skill() -> void:
	print("✅ Skill BOSS berakhir")
	is_skill_active = false
	skill_timer = skill_cooldown
	emit_signal("skill_deactivated")

func trigger_skill_by_health(health_percentage: float) -> void:
	if not is_skill_active and skill_timer <= 0:
		if health_percentage <= trigger_health_percentage:
			skill_timer = 0.1

func _destroy_bullets_in_range() -> void:
	if not enemy:
		return
	
	var bullets = enemy.get_tree().get_nodes_in_group("bullet")
	
	for bullet in bullets:
		if is_instance_valid(bullet):
			var distance = enemy.global_position.distance_to(bullet.global_position)
			if distance <= bullet_clear_radius:
				bullet.queue_free()

func _clear_bullets_in_area() -> void:
	if not enemy:
		return
	
	var bullets = enemy.get_tree().get_nodes_in_group("bullet")
	var bullets_cleared = 0
	
	for bullet in bullets:
		if is_instance_valid(bullet):
			var distance = enemy.global_position.distance_to(bullet.global_position)
			if distance <= bullet_clear_radius:
				bullet.queue_free()
				bullets_cleared += 1
	
	print("💥 BOSS menghapus " + str(bullets_cleared) + " bullet")
