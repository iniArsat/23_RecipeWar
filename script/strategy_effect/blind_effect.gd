extends StatusEffect
class_name BlindEffect

@export var effect_name: String = "BLIND"
@export var duration: float = 3.0
@export var power: float = 0.0  # untuk slow, burn damage, dll
@export var color: Color = Color.DARK_MAGENTA
var timer: float = 3.0

func apply(enemy: Node) -> void:
	enemy.current_target_tower = null
	enemy.towers_in_range.clear()
	enemy._show_status("BLIND", color)

func update(enemy: Node, delta: float) -> void:
	timer -= delta
	if timer <= 0:
		remove(enemy)

func remove(enemy: Node) -> void:
	enemy._hide_status()

func is_finished() -> bool:
	return timer <= 0

func _init():
	timer = duration
