extends StatusEffect
class_name FreezeEffect

@export var effect_name: String = "FREEZE"
@export var duration: float = 2.0
@export var power: float = 0.0  # untuk slow, burn damage, dll
@export var color: Color = Color.SKY_BLUE
var timer: float = 0.0
var original_speed: float = 0.0

func apply(enemy: Node) -> void:
	original_speed = enemy.speed
	enemy.speed = 0
	enemy._show_status("FROZEN", color)

func update(enemy: Node, delta: float) -> void:
	timer -= delta
	if timer <= 0:
		remove(enemy)

func remove(enemy: Node) -> void:
	enemy.speed = enemy.original_speed
	enemy._hide_status()

func is_finished() -> bool:
	return timer <= 0
	
func _init():
	timer = duration
