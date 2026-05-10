class_name Fruit
extends StaticBody2D

var rigid = preload("res://Fruits/Scene/manog.tscn").instantiate()



# Called when the node enters the scene tree for the first time.
func Fruit() -> void:
	rigid.global_position = global_position
	get_parent().add_child(rigid)
	queue_free()
