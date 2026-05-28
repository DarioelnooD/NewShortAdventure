extends RigidBody2D

var live: int = 100
var _body

func _process(delta: float) -> void:
	$live.text = str(live)
	if live <= 0:
		$GPUParticles2D.emitting = true
		rotation = 0
		live = 100
		position = Vector2(813,492)
	if _body:
		$AnimationPlayer.play("Damage")
	
func damage():
	live -= 10

func _on_damage_detecte_body_entered(body: Node2D) -> void:
	if body is Machete:
		_body = body

func _on_damage_detecte_body_exited(body: Node2D) -> void:
	if body is Machete:
		_body = null
