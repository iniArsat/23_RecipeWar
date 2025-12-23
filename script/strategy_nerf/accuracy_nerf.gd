extends NerfEffect
class_name AccuracyNerf

@export var nerf_name: String = "accuracy"
@export var power: float = 0.75
@export var duration: float = 3.0
var original_accuracy: float = 1.0

func apply(tower: TowerBase) -> void:
	original_accuracy = tower.original_accuracy
	tower.original_accuracy = original_accuracy * power
	tower._show_nerf_status("ACCURACY DOWN", Color.RED)
	print("🎯 Accuracy nerf applied: ", tower.original_accuracy)
	timer = duration

func remove(tower: TowerBase) -> void:
	tower.original_accuracy = original_accuracy
	tower._hide_nerf_status()
	print("✅ Accuracy nerf removed")
