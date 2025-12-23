extends Resource
class_name NerfEffect

var timer: float = 0.0

# Virtual methods
func apply(tower: TowerBase) -> void:
	pass

func update(tower: TowerBase, delta: float) -> void:
	timer -= delta
	if timer <= 0:
		remove(tower)

func remove(tower: TowerBase) -> void:
	pass

func is_finished() -> bool:
	return timer <= 0
