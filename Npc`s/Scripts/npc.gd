extends CharacterBody2D

var direction = 20
var is_dialog = false
var object
var id = 0

var lastDirection: int = 20
var WepointIndex: int = 0
var min_distance = 0.2

@export var speed: float
@export var Wepoint: Array[Marker2D]
@onready var dialog_box: RichTextLabel = $DialogoBox

func _ready() -> void:
	object = DataManager.load_csv_data("res://Scripts/DialogosNpc.csv")
	$AnimationPlayer.play("IDLE")
	dialog_box.visible = false
	print(object)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = direction
	
	if is_dialog:
		lastDirection = direction
		direction = 0
	else:
		direction = lastDirection
	
	#if direction < 0:
		#$Body.scale.x = -0.029
	#elif direction > 0:
		#$Body.scale.x = 0.029
	
	if velocity.x != 0 and !is_dialog:
		$AnimationPlayer.play("WALK")
	else:
		$AnimationPlayer.play("IDLE")
	
	move()
	move_and_slide()

func move():
	var wepo = Wepoint[WepointIndex].global_position
	var direction = wepo - self.global_position
	var distance = direction.length()
	
	if distance < min_distance:
		WepointIndex += 1
		
		if WepointIndex >= Wepoint.size():
			WepointIndex = 0
			
		return 

	direction = direction.normalized()
	velocity = direction * speed
	
	move_and_slide()

func dialog():
	is_dialog = true
	dialog_box.visible = true
	id += 1
	if id > object.size():
		id = 0
		is_dialog = false
		dialog_box.visible = false
		return
	var key = str(id)
	dialog_box.text = object[key].DIalogo_eN
	print(object[key].Nombre, object[key].DIalogo_eS, object[key].DIalogo_eN, object[key].Emocion)

func Bocadillo():
	$Burbuja.visible = !$Burbuja.visible
