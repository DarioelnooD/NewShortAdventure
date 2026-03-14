extends Node

var Inicio := false

var LastScene: PackedScene;
var savePosition

func LastPosition(position: Vector2):
	savePosition = position;
	print(savePosition)
	return savePosition
