extends NerfEffect
class_name MirrorDamageNerf

@export var nerf_name: String = "mirror_damage"
@export var power: float = 0.5

func apply(tower: TowerBase) -> void:
	var mirror_damage = tower.max_health * power
	tower.take_damage(mirror_damage)
	print("💔 Mirror damage applied: ", mirror_damage)
