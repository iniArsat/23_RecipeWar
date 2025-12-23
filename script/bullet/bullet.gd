extends Area2D

@export var speed = 0.0
@export var damage = 0.0
@export var rotation_speed = 3.0  # semakin tinggi, semakin cepat belok
var target: Node2D = null

@export var strategy : StatusEffect
	
func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
	var dir = (target.global_position - global_position).normalized()
	rotation = dir.angle()  # Langsung menghadap target
	position += dir * speed * delta 

func _on_body_entered(body: Node2D) -> void:
	#body harus jelas, node2d terlalu luas
	if not body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	if strategy and body.has_method("add_status_effect"):
			body.add_status_effect(strategy)
			#strategy harusnya status effect namanya

	queue_free()
	
func reverse_direction():
	rotation += PI 

# Method untuk increase damage
func increase_damage(new_damage: float):
	damage = new_damage
