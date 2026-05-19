extends Node

var Inicio := false

var LastScene: PackedScene;
var savePosition : Vector2
var saldo: float = 100
#var _bodyPosition: Vector3 = Vector3.ZERO

func LastPosition(position: Vector2 = Vector2(-1335,-15)):
	savePosition = position;
	print(savePosition)
	return savePosition


func Inventory(name: String = '', cantidad: int = 0):
	var sal: int = 0
	var sugar: int = 0
	var Mangos := 0.0
	
	#if Input.is_action_just_pressed("ui_accept") and fruit:
		#Mangos += 1
		#fruit.queue_free()
