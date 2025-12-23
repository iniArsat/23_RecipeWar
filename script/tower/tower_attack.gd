extends TowerBase

@export var bullet_scene: PackedScene
var target = null
var can_shoot = true
var enemies_in_area: Array = []

@onready var head: Sprite2D = $Head
@onready var area: Area2D = $Sight
@onready var collision: CollisionShape2D = $Sight/CollisionShape2D

func _tower_specific_ready():
	_set_initial_head_sprite()
	can_shoot = true
	original_accuracy = 1.0

func _tower_specific_update(delta: float):
	if is_destroyed:
		return
		
	if is_instance_valid(target):
		_rotate_towards_target()
		if can_shoot:
			_shoot()
	else:
		_update_target()

func _rotate_towards_target():
	if is_instance_valid(target):
		head.look_at(target.global_position)
		head.rotation += deg_to_rad(90)

func _shoot():
	if not bullet_scene or not can_shoot:
		return
	
	can_shoot = false
	
	# Cek accuracy sebelum menembak
	if randf() > original_accuracy:
		print("❌ Tower miss!")
		if is_instance_valid(target) and target.has_method("add_miss"):
			target.add_miss()
		await get_tree().create_timer(cooldown).timeout
		can_shoot = true
		return
	
	if is_instance_valid(target) and target.has_method("reset_miss"):
		target.reset_miss()
	
	# SEBELUM menembak, cek jika tower punya mirror damage nerf
	var should_reflect = false
	for nerf in active_nerfs:
		if nerf is MirrorDamageNerf:
			should_reflect = true
			break
	
	var bullet = bullet_scene.instantiate()
	var aim = get_node_or_null("Aim")
	
	if aim:
		bullet.global_position = aim.global_position
		bullet.rotation = (target.global_position - aim.global_position).angle()
	
	# Kirim target ke peluru
	bullet.target = target
	bullet.damage = bullet_damage
	bullet.speed = bullet_speed
	
	# JIKA ADA MIRROR DAMAGE, APLIKASI KE DIRI SENDIRI
	if should_reflect:
		var reflect_damage = bullet_damage * 3.5  # 50%
		print("🔄 Tower will reflect ", reflect_damage, " damage to self")
		take_damage(reflect_damage)
				
	get_tree().get_root().add_child(bullet)
	
	await get_tree().create_timer(cooldown).timeout
	can_shoot = true

func _disable_attacks(duration: float):
	can_shoot = false
	await get_tree().create_timer(duration).timeout
	can_shoot = true

func _on_area_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if not body in enemies_in_area:
			enemies_in_area.append(body)
		if enemies_in_area.size() == 1:
			var range_visual = get_node_or_null("Range_Visual")
			if range_visual:
				range_visual.visible = true
		if target == null:
			_update_target()

func _on_area_body_exited(body: Node2D):
	if body.is_in_group("player"):
		enemies_in_area.erase(body)
		if body == target:
			_update_target()
		if enemies_in_area.is_empty():
			var range_visual = get_node_or_null("Range_Visual")
			if range_visual:
				range_visual.visible = false

func _update_target():
	if is_destroyed:
		target = null
		return
	
	if enemies_in_area.size() > 0:
		# Cari enemy terdekat atau pertama
		target = enemies_in_area[0]
	else:
		target = null

func _set_initial_head_sprite():
	if upgrade_level == 1:
		if head_texture_level1:
			head.texture = head_texture_level1
