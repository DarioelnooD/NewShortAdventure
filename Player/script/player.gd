extends CharacterBody2D

var jump_velocity = -250.0
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

@onready var ray_climb: RayCast2D = $CollisionShape2D/RayCast2D
@onready var f_rom: TileMapLayer = $"../Map/Back"
const BULLET = preload("uid://dycbl14hyfvbc")

var speed = 150.0
var top_speed = 150.0
var current_state: STATE
var save: Array = []
var dead_zone = 1000
var coyote_time := 0.15
var coyote_timer := 0.0
var fruit = null

var climb = false
var one_shot = false

var stamine : float = 50.0
var top_climb : float = 20.0
var stattic_climb : float = 0.07
var move_climb : float = 0.1
var save_climb : float = 0.5
var shoot := false
var power := 0.0
var _body
var menu: bool = false

var selected_index := 0
var inventory_cache := []

var book_open := false
var target_book_position := Vector2(-1, 494.0)

func _ready():
	$Book.visible = true
	$Book.position = Vector2(-1, 494.0)
	$Camera2D.zoom = Vector2(2,2)
	stamine = top_climb
	current_state = STATE.IDLE
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	$base/ColorRect.size.y = stamine

	if not is_on_floor() and climb == false:
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = coyote_time
		one_shot = false
		if stamine <= top_climb:
			stamine += save_climb
	else:
		coyote_timer -= delta
	if !menu:
		move_set()
		detectar_arbol()
	check_point(self.position)
	inventory(delta)
	statemachine()
	move_and_slide()

func _process(delta: float) -> void:
	if get_node(".").get_parent().name == "Pueblo":
		$Camera2D.zoom = $Camera2D.zoom.lerp(Vector2(3.5, 3.5), 3.5 * delta)
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
	
	$Book.position = $Book.position.lerp(
		target_book_position,
		8.0 * delta
	)

func move_set():
	if Input.is_action_just_pressed("JUMP") and coyote_timer > 0 or Input.is_action_just_pressed("JUMP") and climb:
		climb = false
		velocity.y = jump_velocity
		coyote_timer = 0
	
	var left := Input.is_action_pressed("Left")
	var right := Input.is_action_pressed("Right")

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
		speed = top_speed / 3
	else:
		speed = top_speed
	
	if stamine <= 0.05:
		climb = false
		one_shot = false
	
	# Flip del sprite
	if direction < 0:
		$Body.scale.x = -0.029
	elif direction > 0:
		$Body.scale.x = 0.029

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
			top_speed = 90
			$AnimationPlayer.play("IDLE")
			
			$Power.visible = false
			
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
			top_speed = 200
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
			jump_velocity = -250
			
			# DETECCION DE BORDE
			if ray_climb.is_colliding() and Input.is_action_pressed("JUMP") and !$CollisionShape2D/Verificar.is_colliding():
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
			top_speed = 90
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
			if $AnimationPlayer.current_animation == "COLLECT":
				return
			if not fruit and not _body:
				$AnimationPlayer.play("ATTACK")
			if _body and _body.has_method("menu"):
				_body.menu()
				menu = true
			if fruit and is_instance_valid(fruit):
				$AnimationPlayer.play("COLLECT")
				Global.save_inventory(fruit.name,1,"Fresco",2)
				fruit.queue_free()
				fruit = null
				return
			
			if menu:
				if Input.is_action_just_pressed("Down"):
					_body.selec1()
				if Input.is_action_just_pressed("Up"):
					_body.selec_1()
				
				if Input.is_action_just_pressed("ATTACK"):
					menu = false
					current_state = STATE.IDLE
					
				#_physics_process(true)
			#if $AnimationPlayer.current_animation != "ATTACK":
				#$AnimationPlayer.play("ATTACK")
		STATE.CLIMB:
			velocity = Vector2.ZERO
			jump_velocity = -350
			stamine += -stattic_climb
			#climb = true
			$AnimationPlayer.play("climb")
			if stamine < 0:
				current_state = STATE.IDLE
				#climb = false
			if Input.is_action_just_pressed("JUMP"):
				velocity.y = jump_velocity;
				current_state = STATE.JUMP
		STATE.ROLL:
			if $AnimationPlayer.current_animation != "ROLL":
				$AnimationPlayer.play("ROLL")
		STATE.SHOOT:
			$Power.visible = true
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
		$Label.text = "climb"
	if current_state == STATE.ROLL:
		$Label.text = "ROLL"
	if current_state == STATE.SHOOT:
		$Label.text = "SHOOT"

func check_point(position_floor: Vector2):
	$position.text = str(save)
	if self.position.y > dead_zone:
		var res = 0
		if save.size() > 0:
			self.position = save[res]
			if not is_on_floor():
				res += 1
	if is_on_floor() and $SafeFloor/right.is_colliding() and $SafeFloor/left.is_colliding():
		if save.is_empty() or save[0] != position_floor:
			save.push_front(position_floor)
	if save.size() > 3:
		save.pop_back()

func detectar_arbol():
	if _body and _body.name == "Tree":
		if Input.is_action_pressed("Up") and stamine > 0:
			if one_shot == false:
				velocity.y = 0
				one_shot = true
			climb = true
			velocity.y += -1
			stamine -= move_climb
		elif climb and stamine:
			velocity.y = 0
			stamine += -stattic_climb

func stop_attack():
	current_state = STATE.IDLE

func live():
	print("live")

##########################################
##------------INVENTARIO----------------##
##########################################

func inventory(delta):
	$Book.position = $Book.position.lerp(
		target_book_position,
		8.0 * delta
	)
	if Input.is_action_just_pressed("PAUSE"):
		book_open = !book_open
		if book_open:
			$Book.visible = true
			target_book_position = Vector2(-1, -34)
			inventory_cache = Global.get_inventory_to_array()
			for i in range(inventory_cache.size()):
				var item = inventory_cache[i]
				var slot_name = item["Slot"]
				var slot = $"Book/Cuadrilla".get_node(slot_name)
				if slot:
					slot.texture = load("res://icon.svg")
					slot.get_node("Cantidad").text = str(int(item["Cantidad"]))
			selected_index = 0
			update_selected_item()
		else:
			target_book_position = Vector2(-1, 494.0)

func _on_slot_click(event: InputEvent, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected_index = index
			update_selected_item()

func update_selected_item():

	if inventory_cache.is_empty():
		return

	selected_index = clamp(selected_index, 0, inventory_cache.size() - 1)

	var item = inventory_cache[selected_index]

	$Book/DetailItem/ItemCount.text = str(int(item["Cantidad"]))
	$Book/DetailItem/Title.text = str(item["Name"])
	$Book/DetailItem/State.text = str(item["Estado"])

	update_cursor()
	update_quality(int(item["Calidad"]))

func update_quality(value):

	$Book/DetailItem/Calidad/Start.visible = value >= 0
	$Book/DetailItem/Calidad/Start2.visible = value >= 1
	$Book/DetailItem/Calidad/Start3.visible = value >= 2
	$Book/DetailItem/Calidad/Start4.visible = value >= 3

	match value:
		0:
			$Book/DetailItem/Calidad.modulate = Color.WHITE
		1:
			$Book/DetailItem/Calidad.modulate = Color("#979797")
		2:
			$Book/DetailItem/Calidad.modulate = Color("#ff9871")
		3:
			$Book/DetailItem/Calidad.modulate = Color("#e9c63e")

func update_cursor():
	if inventory_cache.is_empty():
		return
	if !$Book.has_node("Selector"):
		return
	var item = inventory_cache[selected_index]
	var slot_name = item["Slot"]
	if !$"Book/Cuadrilla".has_node(slot_name):
		return
	var slot = $"Book/Cuadrilla".get_node(slot_name)
	if slot:
		$Book/Selector.global_position = slot.global_position

func _input(event):
	if !$Book.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for i in range(inventory_cache.size()):
				var item = inventory_cache[i]
				var slot_name = item["Slot"]
				if !$"Book/Cuadrilla".has_node(slot_name):
					continue
				var slot = $"Book/Cuadrilla".get_node(slot_name)
				if !slot:
					continue
				if !slot.texture:
					continue
				var texture_size = slot.texture.get_size()
				var rect = Rect2(
					slot.global_position - texture_size / 2,
					texture_size
				)
				if rect.has_point(event.position):
					selected_index = i
					update_selected_item()
					break

##########################################
##----------//INVENTARIO//--------------##
##########################################



##########################################
##--------------Signal------------------##
##########################################

func _on_collect_body_entered(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		fruit = body
		print("fruit")

func _on_collect_body_exited(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		fruit = null
		print("no fruit")

func _on_collect_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_body = area
		print("body on: ", _body)

func _on_collect_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_body = null
		print("body off: ", _body)

func _on_animation_finished(anim_name):
	if anim_name == "ATTACK":
		current_state = STATE.IDLE
	if anim_name == "ROLL":
		current_state = STATE.WALK

##########################################
##------------//Signal//----------------##
##########################################
