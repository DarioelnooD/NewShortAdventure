extends Node

var Inicio := false

var LastScene: PackedScene;
var savePosition : Vector2
#var _bodyPosition: Vector3 = Vector3.ZERO

func LastPosition(position: Vector2 = Vector2(-1335,-15)):
	savePosition = position;
	print(savePosition)
	return savePosition
