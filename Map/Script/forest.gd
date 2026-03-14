extends Node2D

func _on_pueblo_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.LastPosition(body.position)
		get_tree().change_scene_to_file("res://Map/Scene/pueblo.tscn")


func _on_base_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.LastPosition(body.position)
		get_tree().change_scene_to_file("res://Map/Scene/map_test.tscn")
