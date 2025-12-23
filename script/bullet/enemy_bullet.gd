extends Area2D


@export var speed := 180.0
var target: Node = null
var nerf_type: String = ""
var nerf_power: float = 0.0
var nerf_duration: float = 3.0
@export var tower_damage: float = 0.0

@export var nerf_effect_resource: NerfEffect


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	
	# Bergerak menuju target
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Rotasi bullet menghadap target
	rotation = direction.angle()
	
	# Cek jika sudah mencapai target
	if global_position.distance_to(target.global_position) < 10.0:
		_hit_tower()

func _hit_tower():
	if is_instance_valid(target):
		# Berikan damage ke tower
		if target.has_method("take_damage"):
			target.take_damage(tower_damage)
		
		# SISTEM BARU: Gunakan resource nerf jika ada
		if nerf_effect_resource and target.has_method("apply_nerf_resource"):
			target.apply_nerf_resource(nerf_effect_resource.duplicate())
		# FALLBACK: Sistem lama
		elif nerf_type != "" and target.has_method("apply_nerf"):
			target.apply_nerf(nerf_type, nerf_power, nerf_duration)
	
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == target:
		_hit_tower()
