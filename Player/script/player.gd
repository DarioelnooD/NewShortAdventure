extends CharacterBody2D

const JUMP_VELOCITY = -250.0
enum STATE {
	IDLE,
	RUNNING,
	FALL,
	JUMP,
	WALK,
	ATTACK,
	CLIMB,
	ROLL
}

@onready var Climb: RayCast2D = $Sprite/RayCast2D

var speed = 150.0
var current_state: STATE
var save: Array = []
var deadZone = 1000
var coyote_time := 0.15
var coyote_timer := 0.0


func _ready() -> void:
	$Camera2D.zoom = Vector2(2,2)
	$Camera2D.position = Vector2(0,0)
	current_state = STATE.IDLE
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("JUMP") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	CheckPoint(self.position)
	statemachine()
	move_and_slide()

func _process(delta: float) -> void:
	if $Sprite.flip_h:
		$Sprite/RayCast2D.position.x = -9
		$Sprite/RayCast2D.target_position.y = -15
	else:
		$Sprite/RayCast2D.position.x = 9
		$Sprite/RayCast2D.target_position.y = 15

func statemachine():
	validation()
	match current_state:
		STATE.IDLE:
			speed = 90
			$AnimationPlayer.play("IDLE")

			if velocity.x != 0:
				current_state = STATE.WALK

			if Input.is_action_pressed("RUN") and velocity.x:
				current_state = STATE.RUNNING

			if Input.is_action_just_pressed("JUMP"):
				current_state = STATE.JUMP

			if Input.is_action_just_pressed("ATTACK"):
				current_state = STATE.ATTACK

			if velocity.y > 0:
				current_state = STATE.FALL
		STATE.RUNNING:
			speed = 200
			$AnimationPlayer.play("RUN")

			if !Input.is_action_pressed("RUN"):
				current_state = STATE.WALK

			if velocity.x != 0:
				$Sprite.flip_h = velocity.x < 0

			if velocity.x == 0:
				current_state = STATE.IDLE

			if velocity.y > 0:
				current_state = STATE.FALL
			
			if Input.is_action_just_pressed("ROLL"):
				current_state = STATE.ROLL

			if Input.is_action_just_pressed("JUMP"):
				current_state = STATE.JUMP

			if Input.is_action_just_pressed("ATTACK"):
				current_state = STATE.ATTACK
		STATE.FALL:
			$AnimationPlayer.play("FALL")

			# DETECCION DE BORDE
			if Climb.is_colliding() and Input.is_action_pressed("JUMP") and !$Sprite/Verificar.is_colliding():
				current_state = STATE.CLIMB

			if is_on_floor() and velocity.x == 0:
				current_state = STATE.IDLE

			if is_on_floor() and velocity.x != 0:
				current_state = STATE.WALK

			if is_on_floor() and velocity.x != 0 and Input.is_action_pressed("RUN"):
				current_state = STATE.RUNNING
		STATE.JUMP:
			if $AnimationPlayer.current_animation != "JUMP":
				$AnimationPlayer.play("JUMP")

			if velocity.y > 0:
				current_state = STATE.FALL
		STATE.WALK:
			speed = 90
			$AnimationPlayer.play("WALK")

			if velocity.y > 0:
				current_state = STATE.FALL

			if velocity.x != 0:
				$Sprite.flip_h = velocity.x < 0

			if velocity.x == 0:
				current_state = STATE.IDLE
				
			if Input.is_action_just_pressed("ROLL"):
				current_state = STATE.ROLL

			if Input.is_action_pressed("RUN"):
				current_state = STATE.RUNNING

			if Input.is_action_just_pressed("JUMP"):
				current_state = STATE.JUMP

			if Input.is_action_just_pressed("ATTACK"):
				current_state = STATE.ATTACK
		STATE.ATTACK:
			velocity.x = 0
			if $AnimationPlayer.current_animation != "ATTACK":
				$AnimationPlayer.play("ATTACK")
		STATE.CLIMB:
			velocity = Vector2.ZERO
			$AnimationPlayer.play("CLIMB")
			if Input.is_action_just_pressed("JUMP"):
				velocity.y = JUMP_VELOCITY;
				current_state = STATE.JUMP
		STATE.ROLL:
			if $AnimationPlayer.current_animation != "ROLL":
				$AnimationPlayer.play("ROLL")

func validation():
	if current_state == STATE.IDLE:
		$Label.text = "IDLE"
	if current_state == STATE.RUNNING:
		$Label.text = "RUNNING"
	if current_state == STATE.FALL:
		$Label.text = "FALL"
	if current_state == STATE.JUMP:
		$Label.text = "JUMP"
	if current_state == STATE.WALK:
		$Label.text = "WALK"
	if current_state == STATE.ATTACK:
		$Label.text = "ATTACK"
	if current_state == STATE.CLIMB:
		$Label.text = "CLIMB"
	if current_state == STATE.ROLL:
		$Label.text = "ROLL"

func CheckPoint(PositionFloor: Vector2):
	$position.text = str(save)
	if self.position.y > deadZone:
		var res = 0
		self.position = save[res]
		if not is_on_floor():
			res += 1
	if is_on_floor():
		if save.is_empty() or save[0] != PositionFloor:
			save.push_front(PositionFloor)
	if save.size() > 3:
		save.pop_back()


func _on_animation_finished(anim_name):
	if anim_name == "ATTACK":
		current_state = STATE.IDLE
	if anim_name == "ROLL":
		current_state = STATE.WALK
