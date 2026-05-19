extends CharacterBody2D

var JUMP_VELOCITY = -250.0
enum STATE {
	IDLE,
	RUNNING,
	FALL,
	JUMP,
	WALK,
	ATTACK,
	CLIMB,
	ROLL,
	SHOOT
}

@onready var Climb: RayCast2D = $CollisionShape2D/RayCast2D
@onready var f_rom: TileMapLayer = $"../Map/Back"
const BULLET = preload("uid://dycbl14hyfvbc")

var speed = 150.0
var topSpeed = 150.0
var current_state: STATE
var save: Array = []
var deadZone = 1000
var coyote_time := 0.15
var coyote_timer := 0.0
var fruit = null

var climb = false
var oneShot = false

var stamine : float = 50.0
var TopClimb : float = 20.0
var StaticClimb : float = 0.07
var MoveClimb : float = 0.1
var SaveClimb : float = 0.5
var shoot := false
var power := 0.0
var _body
var menu: bool = false


func _ready() -> void:
	$Camera2D.zoom = Vector2(2,2)
	stamine = TopClimb
	
	#$Camera2D.position = Vector2(0,0)
	current_state = STATE.IDLE
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	detectar_arbol()
	$base/ColorRect.size.y = stamine


	if not is_on_floor() and climb == false:
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = coyote_time
		oneShot = false
		if stamine <= TopClimb:
			stamine += SaveClimb
	else:
		coyote_timer -= delta
	if !menu:
		MoveSet()
	CheckPoint(self.position)
	#Inventory()
	statemachine()
	move_and_slide()

func _process(delta: float) -> void:
	$Saldo.text = str("$",Global.saldo)
	delta = delta + 0
	if $Body.scale.x < 0:
		$CollisionShape2D/RayCast2D.position.x = -3
		$CollisionShape2D/RayCast2D.target_position.y = -15
		$CollisionShape2D/Verificar.position.x = -2
		$CollisionShape2D/Verificar.target_position.y = -25
	elif $Body.scale.x > 0:
		$CollisionShape2D/RayCast2D.position.x = 3
		$CollisionShape2D/RayCast2D.target_position.y = 15
		$CollisionShape2D/Verificar.position.x = 2
		$CollisionShape2D/Verificar.target_position.y = 25

func MoveSet():
	if Input.is_action_just_pressed("JUMP") and coyote_timer > 0 or Input.is_action_just_pressed("JUMP") and climb:
		climb = false
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0


	
	var left := Input.is_action_pressed("ui_left")
	var right := Input.is_action_pressed("ui_right")

	var direction := 0

	if left and not right:
		direction = -1
	elif right and not left:
		direction = 1
	elif left and right:
		if velocity.x > 0:
			$AnimationPlayer.play("SLITE")
			direction = 1
		else:
			direction = -1
		#direction = velocity.x > 0: ? 1 : -1 # mantiene la dirección actual
	if climb == true:
		speed = topSpeed / 3
	else:
		speed = topSpeed
	
	if stamine <= 0.05:
		climb = false
		oneShot = false
	
	# Flip del sprite
	if direction < 0:
		$Body.scale.x = -0.029
	elif direction > 0:
		$Body.scale.x = 0.029

# Movimiento
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func statemachine():
	validation()
	$Stamine.text = str(stamine)
	$Power.text = str(power)
	match current_state:
		STATE.IDLE:
			topSpeed = 90
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
			
			if Input.is_action_just_pressed("AIM"):
				current_state = STATE.SHOOT
		STATE.RUNNING:
			topSpeed = 200
			$AnimationPlayer.play("RUN")

			if !Input.is_action_pressed("RUN"):
				current_state = STATE.WALK

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
			$AnimationPlayer.play("JUMP")
			JUMP_VELOCITY = -250
			
			# DETECCION DE BORDE
			if Climb.is_colliding() and Input.is_action_pressed("JUMP") and !$CollisionShape2D/Verificar.is_colliding():
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
			topSpeed = 90
			$AnimationPlayer.play("WALK")

			if velocity.y > 0:
				current_state = STATE.FALL

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
			if _body and _body.has_method("menu"):
				_body.menu()
				menu = true
			elif Input.is_action_just_pressed("ATTACK"):
				menu = false
				print("move")
				current_state = STATE.IDLE
				
			if menu:
				if Input.is_action_just_pressed("ui_down"):
					_body.selec1()
				if Input.is_action_just_pressed("ui_up"):
					_body.selec_1()
				
				if Input.is_action_just_pressed("ATTACK"):
					menu = false
					current_state = STATE.IDLE
					
				#_physics_process(true)
			#if $AnimationPlayer.current_animation != "ATTACK":
				#$AnimationPlayer.play("ATTACK")
		STATE.CLIMB:
			velocity = Vector2.ZERO
			JUMP_VELOCITY = -350
			
			$AnimationPlayer.play("CLIMB")
			if Input.is_action_just_pressed("JUMP"):
				velocity.y = JUMP_VELOCITY;
				current_state = STATE.JUMP
		STATE.ROLL:
			if $AnimationPlayer.current_animation != "ROLL":
				$AnimationPlayer.play("ROLL")
		STATE.SHOOT:
			$AnimationPlayer.play("Shoot")
			var mouse_pos = get_global_mouse_position()
			$Body/stomach.look_at(mouse_pos)
			if Input.is_action_just_pressed("AIM"):
				current_state = STATE.IDLE
			if Input.is_action_pressed("SHOOT"):
				shoot = true
				if power < 1000:
					power += 10
			elif shoot:
				var bullet = BULLET.instantiate()
				var direction = (
					get_global_mouse_position() - global_position
				).normalized()
				bullet.global_position = $Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand.global_position
				bullet.apply_impulse(direction * power)
				get_tree().current_scene.add_child(bullet)
				power = 0
				shoot = false

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
	if current_state == STATE.SHOOT:
		$Label.text = "SHOOT"

func CheckPoint(PositionFloor: Vector2):
	$position.text = str(save)
	if self.position.y > deadZone:
		var res = 0
		if save.size() > 0:
			self.position = save[res]
			if not is_on_floor():
				res += 1
	if is_on_floor():
		if save.is_empty() or save[0] != PositionFloor:
			save.push_front(PositionFloor)
	if save.size() > 3:
		save.pop_back()

func detectar_arbol():
	if Input.is_action_pressed("ui_up") and stamine > 0:
		if oneShot == false:
			velocity.y = 0
			oneShot = true
		climb = true
		velocity.y += -1
		stamine -= MoveClimb
	elif climb and stamine:
		velocity.y = 0
		stamine += -StaticClimb

func _on_animation_finished(anim_name):
	if anim_name == "ATTACK":
		current_state = STATE.IDLE
	if anim_name == "ROLL":
		current_state = STATE.WALK



func _on_collect_body_entered(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		fruit = body
		print("fuit")

func _on_collect_body_exited(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		fruit = null
		print("no fuit")

func _on_collect_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_body = area
		print("body on: ", _body)

func _on_collect_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_body = null
		print("body off: ", _body)
