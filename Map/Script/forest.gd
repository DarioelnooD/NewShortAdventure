extends Node2D

var _Body: CharacterBody2D

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("JUMP"):
		#$Puente/T4toT5.node_a = NodePath()
		#$Puente/T4toT5.node_b = NodePath()

func _ready() -> void:
	var child = $Base.get_children()
	for C in child:
		if C.name.contains("Tree"):
			match C.z_index:
				0:
					C.modulate = "#ffffff"
				-5:
					C.modulate = '#a7a7a7'
				-10:
					C.modulate = '#5b5b5b'

	#Global.SaveCurrentScene()  
	if $PLayerCutOut:
		_Body = $PLayerCutOut
	else :
		_Body = get_node("PlayerCut") as CharacterBody2D

	if _Body:
		var post = Global.get_last_position_in_door('forest')
		if post != null:
			_Body.position = Vector2(post["x"], post["y"])
			
			
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") and $Puente/Der/CollisionShape2D:
		$Puente/T7toD.queue_free()
		$Puente/Der/CollisionShape2D.queue_free()

func _on_pueblo_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		#Global.LastPosition(body.position)
		Global.put_last_position_in_door("forest",body.position.x - 5,body.position.y)
		get_tree().change_scene_to_file("res://Map/Scene/pueblo.tscn")


func _on_base_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		#Global.LastPosition(body.position)
		Global.put_last_position_in_door("forest",body.position.x + 5,body.position.y)
		get_tree().change_scene_to_file("res://Map/Scene/map_test.tscn")

func _on_s_pirit_land_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.put_last_position_in_door("forest2",body.position.x - 5,body.position.y)
