extends "res://script/enemies/enemy.gd"  # Inherit dari enemy biasa

# Skill khusus: memantulkan bullet
var reflect_chance := 0.5  # 50% chance memantulkan bullet
var reflect_damage_multiplier := 1.5  # Damage pantulan lebih besar
@onready var bullet_detector: Area2D = $BulletDetector

func _ready():
	super()  # Panggil _ready() dari parent
	# Connect signal untuk bullet detection

# Method untuk handle bullet collision
func _on_bullet_detector_area_entered(area: Area2D) -> void:
	if current_health <= 0 or not is_instance_valid(area):  # Gunakan current_health bukan is_destroyed
		return
	
	if area.is_in_group("bullet") and randf() < reflect_chance:
		_reflect_bullet(area)

func _reflect_bullet(bullet: Area2D) -> void:
	if not is_instance_valid(bullet):
		return
	
	# Reverse direction bullet
	if bullet.has_method("reverse_direction"):
		bullet.reverse_direction()
		# Increase reflected bullet damage
		if bullet.has_method("increase_damage"):
			var original_damage = bullet.damage
			bullet.increase_damage(original_damage * reflect_damage_multiplier)
		
		print("🛡️ Mini Boss memantulkan bullet!")
		
		# Visual effect untuk pantulan
		_show_reflect_effect()
	else:
		# Jika bullet tidak bisa dipantulkan, hancurkan saja
		bullet.queue_free()

func _show_reflect_effect():
	# Buat effect visual pantulan
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GOLD, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
