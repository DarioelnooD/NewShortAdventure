extends Node2D

func _on_viaje_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.LastPosition(body.position)
		get_tree().change_scene_to_file("res://Prue/tuto_map.tscn")
