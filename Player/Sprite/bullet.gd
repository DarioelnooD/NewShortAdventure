extends RigidBody2D


func _ready():
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.15).timeout
	$CollisionShape2D.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("Fruit") and body is Fruit:
		body.Fruit()
	if self and body:
		self.queue_free()
