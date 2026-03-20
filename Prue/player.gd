extends CharacterBody3D



const JUMP_VELOCITY =4.0
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

@onready var rayCast: RayCast3D = $RayCast3D
@export var speedWalk = 25
@export var speedRun = 50

var speed = 50.0
var climbTree = false
var current_state: STATE
var save: Array = []
var deadZone = -30
var coyote_time := 0.15
var coyote_timer := 0.0
var max_stamina := 50.0
var stamina := 50.0
var stamina_drain := 25
var stamina_recover := 15   


func _ready() -> void:
	current_state = STATE.IDLE
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	if Global._bodyPosition != Vector3(0,0,0):
		self.position = Global._bodyPosition

func _physics_process(delta: float) -> void:
	self.position.z = 0
	$Velocidad.text = str(velocity)
	$stamina.text = str(int(stamina))
	if not is_on_floor() and !climbTree:
		velocity += get_gravity() * delta

	if is_on_floor():
		var normal = get_floor_normal()
		align_with_floor(normal)
		coyote_timer = coyote_time
		stamina += stamina_recover * delta
	else:
		coyote_timer -= delta
		align_to_vertical() # 👈 esto es lo que te faltaba

	if Input.is_action_just_pressed("JUMP") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	ClimbTree(delta)
	CheckPoint(self.position)
	statemachine()
	move_and_slide()

func statemachine():
	#validation()
	match current_state:
		STATE.IDLE:
			speed = speedWalk
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
			speed = speedRun
			$AnimationPlayer.play("RUN")
			if !Input.is_action_pressed("RUN"):
				current_state = STATE.WALK

			if velocity.x != 0:
				$Sprite3D.flip_h = velocity.x < 0

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
			if is_on_floor() and velocity.x == 0:
				current_state = STATE.IDLE

			if is_on_floor() and velocity.x != 0:
				current_state = STATE.WALK

			if is_on_floor() and velocity.x != 0 and Input.is_action_pressed("RUN"):
				current_state = STATE.RUNNING
		STATE.JUMP:
			$AnimationPlayer.play("JUMP")
			velocity.y = JUMP_VELOCITY
			if velocity.y > 0:
				current_state = STATE.FALL
		STATE.WALK:
			speed = speedWalk
			$AnimationPlayer.play("WALK")
			if velocity.y > 0:
				current_state = STATE.FALL

			if velocity.x != 0:
				$Sprite3D.flip_h = velocity.x < 0

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
		STATE.CLIMB:
			if not $AnimationPlayer.is_playing() or \
				$AnimationPlayer.current_animation != "CLIEMTREE":
				$AnimationPlayer.play("CLIEMTREE")
			if is_on_floor():
				current_state = STATE.IDLE
			if Input.is_action_just_pressed("JUMP"):
				climbTree = false
				velocity.y = JUMP_VELOCITY
				current_state = STATE.JUMP
		STATE.ROLL:
			pass

#func validation():
	#if current_state == STATE.IDLE:
		#$Label.text = "IDLE"
	#if current_state == STATE.RUNNING:
		#$Label.text = "RUNNING"
	#if current_state == STATE.FALL:
		#$Label.text = "FALL"
	#if current_state == STATE.JUMP:
		#$Label.text = "JUMP"
	#if current_state == STATE.WALK:
		#$Label.text = "WALK"
	#if current_state == STATE.ATTACK:
		#$Label.text = "ATTACK"
	#if current_state == STATE.CLIMB:
		#$Label.text = "CLIMB"
	#if current_state == STATE.ROLL:
		#$Label.text = "ROLL"

func CheckPoint(PositionFloor: Vector3):
	#$position.text = str(save)
	if self.position.y < deadZone:
		var res = 0
		self.position = save[res]
		if not is_on_floor():
			res += 1
	if is_on_floor():
		if save.is_empty() or save[0] != PositionFloor:
			save.push_front(PositionFloor)
	if save.size() > 3:
		save.pop_back()

func align_with_floor(normal: Vector3):
	var up = normal
	var right = Vector3.RIGHT  
	var forward = right.cross(up).normalized()
	right = up.cross(forward).normalized()
	var new_basis = Basis()
	new_basis.x = right    
	new_basis.y = up      
	new_basis.z = forward  #
	$Sprite3D.transform.basis = new_basis
	var dir_x = sign($Sprite3D.scale.x)
	if dir_x == 0: dir_x = 1
	$Sprite3D.scale = Vector3(4.7 * dir_x, 4.7, 4.7)

func align_to_vertical():
	var current_basis = $Sprite3D.transform.basis.orthonormalized()
	var target_basis = Basis()
	var new_basis = current_basis.slerp(target_basis, 0.1)
	$Sprite3D.transform.basis = new_basis
	var dir_x = sign($Sprite3D.scale.x)
	if dir_x == 0: dir_x = 1
	$Sprite3D.scale = Vector3(4.7 * dir_x, 4.7, 4.7)

func ClimbTree(delta):
	var directionY := Input.get_axis("ui_down", "ui_up")
	
	if rayCast.is_colliding() and Input.is_action_pressed("ui_up") and stamina > 0:
		climbTree = true
	if climbTree and (!rayCast.is_colliding() or stamina <= 0):
		climbTree = false
	if climbTree:
		current_state = STATE.CLIMB
		velocity.x = 0
		
		if Input.is_action_just_pressed("ui_accept"): 
			stamina -= 15.0 
			climbTree = false 
			var climb_jump_boost := 5.5 
			velocity.y = JUMP_VELOCITY * climb_jump_boost
			return 
		if directionY > 0: 
			velocity.y = directionY * (speed / 2.0)
			stamina -= stamina_drain * delta
		elif directionY < 0: 
			velocity.y = directionY * (speed / 2.0) * 0.6
			stamina -= stamina_drain * delta
		else: 
			velocity.y = 0
			stamina -= (stamina_drain * 0.3) * delta 
	stamina = clamp(stamina, 0, max_stamina)

func _on_animation_finished(anim_name):
	if anim_name == "ATTACK":
		current_state = STATE.IDLE
	if anim_name == "ROLL":
		current_state = STATE.WALK
	if anim_name == "CLIEMTREE":   # ← esto faltaba
		if is_on_floor():
			current_state = STATE.IDLE
		else:
			current_state = STATE.FALL


func _on_spawn_point_body(body: Node3D) -> void:
	if body is CharacterBody3D:
		Global._bodyPosition = body.position
