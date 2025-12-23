extends StatusEffect
class_name BurnEffect

@export var effect_name: String = "BURN"
@export var duration: float = 2.0
@export var power: float = 2.0  # untuk slow, burn damage, dll
@export var color: Color = Color.RED
var timer: float = 0.0
var tick_timer: float = 0.0
var tick_interval: float = 0.5

func apply(enemy: Node) -> void:
	enemy._show_status("BURN", color)

func update(enemy: Node, delta: float) -> void:
	timer -= delta
	tick_timer -= delta
	
	if tick_timer <= 0:
		enemy.take_damage(int(power * tick_interval))
		tick_timer = tick_interval
	
	if timer <= 0:
		remove(enemy)

func remove(enemy: Node) -> void:
	enemy._hide_status()

func is_finished() -> bool:
	return timer <= 0

func _init():
	timer = duration
	tick_timer = tick_interval
