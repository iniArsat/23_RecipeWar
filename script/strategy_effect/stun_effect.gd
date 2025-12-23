extends StatusEffect
class_name StunEffect

@export var effect_name: String = "BURN"
@export var duration: float = 2.0
@export var power: float = 2.0  # untuk slow, burn damage, dll
@export var color: Color = Color.RED
var timer: float = 0.0
var original_speed: float = 0.0

func apply(enemy: Node) -> void:
	original_speed = enemy.speed
	enemy.speed = 0
	enemy._show_status("STUN", color)

func update(enemy: Node, delta: float) -> void:
	timer -= delta
	if timer <= 0:
		remove(enemy)

func remove(enemy: Node) -> void:
	enemy.speed = enemy.original_speed
	enemy._hide_status()

func _init():
	timer = duration
