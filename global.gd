extends Node

var Inicio := false

var LastScene: PackedScene;
var savePosition
var _bodyPosition: Vector3 = Vector3(0,0,0);

func LastPosition(position: Vector2):
	savePosition = position;
	print(savePosition)
	return savePosition
