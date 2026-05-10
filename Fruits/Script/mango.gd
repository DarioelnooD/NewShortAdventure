extends RigidBody2D

var _body

func _process(delta: float) -> void:
	if self.linear_velocity >= Vector2(0,500) and _body:
		self.queue_free()
	$Label.text = str(self.linear_velocity)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != CharacterBody3D:
		_body = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != CharacterBody3D:
		_body = null
