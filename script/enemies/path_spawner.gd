extends Node2D

@export var path_scene: PackedScene

func _ready():
	# Jika tidak di-set di inspector, gunakan default
	if path_scene == null:
		path_scene = preload("res://scene/path_lvl1.tscn")

func spawn_enemy(enemy_scene: PackedScene) -> Node:
	var temp_path = path_scene.instantiate()
	add_child(temp_path)

	var enemy = enemy_scene.instantiate()
	var follow = temp_path.get_node("PathFollow2D")
	follow.add_child(enemy)
	
	return enemy
