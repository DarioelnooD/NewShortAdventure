extends Node2D


func _ready() -> void:
	$AnimationPlayer.play("Inicio2")




func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/Scene/pueblo.tscn")

func _on_exit_pressed() -> void:
	$AnimationPlayer.play_backwards("Inicio2")
