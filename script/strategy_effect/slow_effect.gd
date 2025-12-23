extends StatusEffect
class_name SlowEffect

@export var effect_name: String = "SLOW"
@export var duration: float = 3.0
@export var power: float = 2.0  # untuk slow, burn damage, dll
@export var color: Color = Color.YELLOW
var timer: float = 0.0
var original_speed: float = 0.0

func apply(enemy: Node) -> void:
	original_speed = enemy.speed
	enemy.speed = enemy.original_speed * (1.0 - power)
	enemy._show_status("SLOW", color)

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
