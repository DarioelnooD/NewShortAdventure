extends CharacterBody2D

var jump_velocity = -250.0
var climb_step = 0

enum STATE {
	IDLE,
	RUNNING,
	FALL,
	JUMP,
	WALK,
	ATTACK,
	CLIMB,
	ROLL,
	CROUCH,
	SHEATHE,
	SHOOT
}
enum CLIMB_LIMB {
	LEFT_FOOT,
	RIGHT_HAND,
	RIGHT_FOOT,
	LEFT_HAND
}
enum STATE_BOOK {
	INVENTORY,
	SETTINGS,
	SHOP,
	MAP
}

@onready var ray_climb: RayCast2D = $CollisionShape2D/RayCast2D
@onready var f_rom: TileMapLayer = $"../Map/Back"
const BULLET = preload("uid://dycbl14hyfvbc")

var LeftHand 
var RightHand 
var LeftFoot 
var RightFoot

var TopLeftHand

var MR: Area2D = null
var ML: Area2D = null
var FR: Area2D = null
var FL: Area2D = null

var speed = 150.0
var top_speed = 150.0
var current_state: STATE
var current_state_book: STATE_BOOK
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
var _area
var menu: bool = false
var NPC:CharacterBody2D;
var selected_index := 0
var inventory_cache := []

var book_open := false
var target_book_position := Vector2(-1, 494.0)

var talking := false
var has_machete := true      
var machete := false         
@export var QuitWindows = false

var book = true

#region godot
##########################################
##----------------GODOT-----------------##
##########################################

func _ready():
	update_machete()
	limbsControl()
	print('inventory childrens: ', $PruebaMouse/Inventory/Node.get_children()) 
	
	$Book.play("On")
	
	Global.ultima_escena = get_tree().current_scene.scene_file_path
	#$Book.visible = true
	#$Book.position = Vector2(-1, 494.0)
	if get_node(".").get_parent().name == "Pueblo":
		$"Book".play("Off")
		$PruebaMouse.scale = Vector2(0.193,0.193) 
	else:
		$"Book".play("OffLarge")
		$PruebaMouse.scale = Vector2(0.357,0.343) 
		$Camera2D.zoom = Vector2(2,2)

	stamine = top_climb
	current_state = STATE.IDLE
	#current_state = STATE.CLIMB
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	var scene = get_tree().current_scene.name
	if scene == "Forest":
		dead_zone = 3000
	else:
		dead_zone = 1000

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
	statemachine()
	move_and_slide()

func _process(delta: float) -> void:
	if get_node(".").get_parent().name == "Pueblo":
		$Camera2D.zoom = $Camera2D.zoom.lerp(Vector2(3.5, 3.5), 3.5 * delta)
	DebugOption()
#	-130 -100
	if Input.is_action_just_pressed("PAUSE"):
		if get_node(".").get_parent().name == "Pueblo":
			if book: $"Book".play("Off")
			else: $"Book".play("On") 
			$PruebaMouse.scale = Vector2(0.193,0.193) 
		else:
			if book: $"Book".play("OffLarge")
			else: $"Book".play("OnLarge") 
			$PruebaMouse.scale = Vector2(0.357,0.343) 

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
	
	#$PruebaMouse.global_position = self.global_position
	#$Book.position = $Book.position.lerp(
		#target_book_position,
		#8.0 * delta
	#)

##########################################
##--------------//GODOT//---------------##
##########################################
#endregion

func update_machete():
	$Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/Sprite2D/Machete.visible = machete
	$Body/stomach/Machete.visible = has_machete and !machete

func move_set():
	if talking:
		velocity.x = 0
		return
	
	if Input.is_action_just_pressed("JUMP") and coyote_timer > 0 or Input.is_action_just_pressed("JUMP") and climb:
		climb = false
		velocity.y = jump_velocity
		coyote_timer = 0
		
	if machete:
		speed = speed - 5
	else:
		speed = top_speed
	
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
		
	if machete:
		#$Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/Sprite2D/Machete.visible = true
		$Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/Sprite2D/Machete.collision_layer = 7
		#$Body/stomach/Machete.visible = false
		$Body/stomach/Machete.collision_layer = 32
		#print("hay machete")
	else:
		#$Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/Sprite2D/Machete.visible = false
		$Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/Sprite2D/Machete.collision_layer = 32
		#$Body/stomach/Machete.visible = true
		$Body/stomach/Machete.collision_layer = 32
		#print("no machete")

		if stamine <= 0.05:
			climb = false
			one_shot = false
	
	# Flip del sprite
	if !climb:
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
			
			if Input.is_action_just_pressed("CROUCH"):
				current_state = STATE.CROUCH
			
			if current_state == STATE.IDLE:
				if $Timer.is_stopped():
					$Timer.start(3.0)
			else:
				$Timer.stop()
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

			if Input.is_action_just_pressed("ATTACK") and machete or Input.is_action_just_pressed("ATTACK") and _area or Input.is_action_just_pressed("ATTACK") and fruit: 
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
			
			if Input.is_action_just_pressed("ATTACK") and machete or Input.is_action_just_pressed("ATTACK") and _area or Input.is_action_just_pressed("ATTACK") and fruit: 
				current_state = STATE.ATTACK
		STATE.ATTACK:
			velocity.x = 0
			if $AnimationPlayer.current_animation == "COLLECT":
				return
			
			if not fruit and not _area and machete:
				$AnimationPlayer.play("ATTACK")
				
			if _area and _area.has_method("menu"):
				_area.menu()
				menu = true
			
			if NPC and NPC.has_method("dialog"):
				if !talking:
					talking = true
					if machete:
						machete = false
						menu = true
					NPC.dialog()
				elif Input.is_action_just_pressed("ATTACK"):
					NPC.dialog()
					if not NPC.is_dialog:
						talking = false
						menu = false
				
			if fruit and is_instance_valid(fruit) and !machete:
				$AnimationPlayer.play("COLLECT")
				var item = fruit.data()
				Global.save_inventory(
					item["Nombre"],
					1,
					item["Estado"],
					item["Calidad"],
					item["Image"]
				)
				fruit.queue_free()
				fruit = null
				return
			
			if menu:
				if Input.is_action_just_pressed("Down"):
					_area.selec1()
				if Input.is_action_just_pressed("Up"):
					_area.selec_1()
				
				if Input.is_action_just_pressed("ATTACK"):
					menu = false
					current_state = STATE.IDLE
					
				#_physics_process(true)
			#if $AnimationPlayer.current_animation != "ATTACK":
				#$AnimationPlayer.play("ATTACK")
			#current_state = STATE.IDLE
			
			if !machete and menu == false and !talking: 
				current_state = STATE.SHEATHE
		STATE.CLIMB:
				
			if Input.is_action_pressed("Up"):
				position.y -= 0.5

			if Input.is_action_pressed("Down"):
				position.y += 0.5
			
			if Input.is_action_just_pressed("JUMP"):
				current_state = STATE.JUMP
			climb = true
			
			if MR:
				var target_r = get_closest_hold_point(MR, $Body/stomach/Chest/RightArmTop.global_position)
				$Body/stomach/Chest/RightArmTop.look_at(target_r)
				$Body/stomach/Chest/RightArmTop/RightArmBottom.look_at(target_r)
				
			if ML:
				var target_l = get_closest_hold_point(ML, $Body/stomach/Chest/LeftArmTop.global_position)
				$Body/stomach/Chest/LeftArmTop.look_at(target_l)
				$Body/stomach/Chest/LeftArmTop/LeftArmBottom.look_at(target_l)
		STATE.ROLL:
			if $AnimationPlayer.current_animation != "ROLL":
				$AnimationPlayer.play("ROLL")
		STATE.CROUCH:
			$AnimationPlayer.play("CROUCH")
			velocity.x = 0
			if Input.is_action_just_pressed("CROUCH"):
				current_state = STATE.IDLE
		STATE.SHOOT:
			$Power.visible = true
			machete = false
			update_machete()
			
			$AnimationPlayer.play("Shoot")
			
			# 1. OBTENER POSICIONES
			var mouse_pos = get_global_mouse_position()
			var mouse_local = $Body/stomach.get_local_mouse_position()
			var angle_to_mouse = mouse_local.angle()
			var limit = deg_to_rad(45)

			# 2. ROTACIÓN FLUIDA DE PECHO Y ESTÓMAGO
			$Body/stomach/Chest.rotation = clamp(angle_to_mouse, -limit, limit)
			var excess = angle_to_mouse - $Body/stomach/Chest.rotation

			if abs(excess) > 0.001:
				$Body/stomach.rotation += excess * 0.1
			
			# 3. CONTROL DE INPUTS Y DISPARO
			if Input.is_action_just_pressed("AIM"):
				current_state = STATE.IDLE
				
			if Input.is_action_pressed("SHOOT"):
				shoot = true
				if power < 1000:
					power += 10
			elif shoot:
				var bullet = BULLET.instantiate()
				
				# Guardamos la posición de la mano para usarla en ambos cálculos
				var hand_pos = $Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand.global_position
				
				# Calculamos la dirección real desde la mano al mouse
				var direction = (mouse_pos - hand_pos).normalized()
				
				bullet.global_position = hand_pos
				bullet.apply_impulse(direction * power)
				get_tree().current_scene.add_child(bullet)
				
				power = 0
				shoot = false
		STATE.SHEATHE:
			if !machete:
				$AnimationPlayer.play_backwards("UNSHEATHE")
			else:
				$AnimationPlayer.play("SHEATHE")

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
	if _area and _area.name == "Tree" or _area and _area.has_meta("Tree"):
		if Input.is_action_pressed("Up") and stamine > 0 and _area != null:
			if one_shot == false:
				velocity.y = 0
				one_shot = true
			climb = true
			if velocity.y > -10:
				velocity.y += -1
			stamine -= move_climb
		elif climb and stamine:
			velocity.y = 0
			stamine += -stattic_climb
	else:
		return

func limbsControl():
	LeftHand = $Body/stomach/Chest/LeftArmTop/LeftArmBottom/Hand/LeftHand
	TopLeftHand = $Body/stomach/Chest/LeftArmTop
	#/LeftArmBottom/Hand/LeftHand
	RightHand = $Body/stomach/Chest/RightArmTop/RightArmBottom/Hand/RightHand
	LeftFoot = $Body/Chip/LeftLegTop/LeftArmBottom/foot/LeftFoot
	RightFoot = $Body/Chip/RightLegTop/RightArmBottom/foot/RightFoot

	LeftHand.collision_layer = 1
	LeftHand.collision_mask = 5
	
	RightHand.collision_layer = 1
	RightHand.collision_mask = 5
	
	LeftFoot.collision_layer = 1
	LeftFoot.collision_mask = 5
	
	RightFoot.collision_layer = 1
	RightFoot.collision_mask = 5

func get_closest_hold_point(node: Node, hand_position: Vector2) -> Vector2:
	var hold_points = node.get_node("HoldPoints")
	var closest_pos = hold_points.get_children()[0].global_position
	var closest_dist = hand_position.distance_to(closest_pos)
	for point in hold_points.get_children():
		var dist = hand_position.distance_to(point.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_pos = point.global_position
	return closest_pos

#region DeBug
##########################################
##----------------DEBUG-----------------##
##########################################

func validation():
	
	$Stamine.text = str(stamine)
	$Power.text = str(power)
	#$Book/Inventario/Saldo.text = str("$",Global.saldo)
	
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
	if current_state == STATE.SHEATHE:
		$Label.text = "SHEATHE:"

func DebugOption():
	if QuitWindows:
		get_tree().quit()

@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 14.0

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var z = $Camera2D.zoom.x - zoom_speed
			z = clamp(z, min_zoom, max_zoom)
			$Camera2D.zoom = Vector2(z, z)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var z = $Camera2D.zoom.x + zoom_speed
			z = clamp(z, min_zoom, max_zoom)
			$Camera2D.zoom = Vector2(z, z)
##########################################
##--------------//DEBUG//---------------##
##########################################
#endregion

#region signal
##########################################
##--------------Signal------------------##
##########################################

func _on_collect_body_entered(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		body.Selecte();
		fruit = body
		print("fruit")
	
	elif body is CharacterBody2D:
		if body.has_method("Bocadillo"): body.Bocadillo()
		NPC = body

func _on_collect_body_exited(body: Node2D) -> void:
	if body is Fruit or body is StaticFruit:
		body.UnSelector();
		fruit = null
		print("no fruit")
	elif body is CharacterBody2D:
		if body.has_method("Bocadillo"): body.Bocadillo()
		NPC = body
	
	elif body is CharacterBody2D:
		if body.has_method("Bocadillo"): body.Bocadillo()
		NPC = body

func _on_collect_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_area = area
		print("area on: ", _area)

func _on_collect_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Area2D:
		_area = null
		print("area off: ", _area)

func _on_animation_finished(anim_name):
	if anim_name == "ATTACK":
		current_state = STATE.IDLE
	if anim_name == "ROLL":
		current_state = STATE.WALK
	if anim_name == "SHEATHE":
		machete = false
		update_machete()
	if anim_name == "UNSHEATHE":
		machete = true
		update_machete()
	current_state = STATE.IDLE

func _on_timer_timeout():
	if current_state == STATE.IDLE and machete and !talking:
		current_state = STATE.SHEATHE

func stop_attack():
	current_state = STATE.IDLE

#region LIMBS
###################
##-----LIMBS-----##
###################

func _on_right_hand_area_entered(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		MR = area
		print("mano derecha")

func _on_right_hand_area_exited(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		MR = null

func _on_left_hand_area_entered(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		ML = area
		print("mano izquierdo")

func _on_left_hand_area_exited(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		ML = null

func _on_right_foot_area_entered(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		FR = area
		print("pie derecho")

func _on_right_foot_area_exited(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		FR = null

func _on_left_foot_area_entered(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		FL = area
		print("pie izquierdo")

func _on_left_foot_area_exited(area: Area2D) -> void:
	if area and area.name.contains("Tree") or area and area.has_meta("Tree"):
		FL = null

###################
##----/LIMBS/----##
###################
#endregion

func _on_map_tip_pressed() -> void:
	current_state_book = STATE_BOOK.MAP

func _on_invent_trip_pressed() -> void:
	current_state_book = STATE_BOOK.INVENTORY
	
func _on_shop_t_ip_pressed() -> void:
	current_state_book = STATE_BOOK.SHOP

func _on_settings_t_ip_pressed() -> void:
	current_state_book = STATE_BOOK.SETTINGS

##########################################
##------------//Signal//----------------##
##########################################
#endregion

func BookOn():
	book = !book
