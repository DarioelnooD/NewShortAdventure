extends Node2D

var _Body: CharacterBody2D

func _ready() -> void:
	#Global.SaveCurrentScene()  
	if $PLayerCutOut:
		_Body = $PLayerCutOut
	else :
		_Body = get_node("PlayerCut") as CharacterBody2D

	if _Body:
		var post = Global.GetLastPositionInDoor("map_test")
		if post != null:
			_Body.position = Vector2(post["x"], post["y"])

func _on_viaje_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_Body = body
		#Global.LastPosition(body.position)
		Global.PutLastPositionInDoor("map_test",body.position.x - 5,body.position.y)
		get_tree().change_scene_to_file("res://Map/Scene/forest.tscn")
