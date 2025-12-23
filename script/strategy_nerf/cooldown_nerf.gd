extends NerfEffect
class_name CooldownNerf

@export var nerf_name: String = "cooldown"
@export var power: float = 0.3
@export var duration: float = 3.0
var original_cooldown: float = 0.0

func apply(tower: TowerBase) -> void:
	original_cooldown = tower.cooldown
	tower.cooldown = original_cooldown + power
	tower._show_nerf_status("COOLDOWN", Color.BLUE_VIOLET)
	print("⏱️ Cooldown nerf applied: ", tower.cooldown)
	timer = duration

func remove(tower: TowerBase) -> void:
	tower.cooldown = original_cooldown
	print("✅ Cooldown nerf removed")
