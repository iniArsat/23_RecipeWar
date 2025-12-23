extends Area2D

@export var speed = 1000.0
@export var damage = 1.0
@export var rotation_speed = 5.0  # semakin tinggi, semakin cepat belok
var target: Node2D = null

func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
	var dir = (target.global_position - global_position).normalized()
	rotation = dir.angle()  # Langsung menghadap target
	position += dir * speed * delta

func _on_body_entered(body: Node2D) -> void:	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
