extends Resource
class_name StatusEffect

# Virtual methods
func apply(enemy: Node) -> void:
	pass

func update(enemy: Node, delta: float) -> void:
	pass

func remove(enemy: Node) -> void:
	pass

func is_finished() -> bool:
	return false
