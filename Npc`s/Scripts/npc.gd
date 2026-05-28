extends CharacterBody2D

var direcction = 20

func _ready() -> void:
	$AnimationPlayer.play("IDLE")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = direcction
	
	if velocity.x > 0:
		$AnimationPlayer.play("WALK")
	else:
		$AnimationPlayer.play("IDLE")
	move()
	move_and_slide()

func move():
	if not $SafeFloor/right.is_colliding():
		direcction = -20
	
	if not $SafeFloor/left.is_colliding():
		direcction = 20
