extends CharacterBody2D

var direction = 20
var is_dialog = false
var object
var id = 0

var lastDirection: int = 20
var WepointIndex: int = 0
var min_distance = 0.2

enum STATE { IDLE,WALK }
var currentState: STATE
var can_move = true

@export var speed: float
@export var Wepoint: Array[Marker2D]
@onready var dialog_box: RichTextLabel = $DialogoBox


func _ready() -> void:
	if $"../MarketList": Wepoint.assign($"../MarketList".get_children(true))
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

	state_machine()
	move_and_slide()

func state_machine():
	match currentState:
		STATE.IDLE:
			velocity.x = 0
			$AnimationPlayer.play("IDLE")
			
		STATE.WALK:
			if is_dialog:
				currentState = STATE.IDLE
				return 
				
			$AnimationPlayer.play("WALK")
			
			var wepo = Wepoint[WepointIndex].global_position
			var direction = wepo - self.global_position
			var distance = direction.length()
			
			$Label.text = str(wepo)
			
			if wepo.x < self.global_position.x:
				$Body.scale.x = -0.029
			elif wepo.x > self.global_position.x:
				$Body.scale.x = 0.029
			
			if distance < min_distance:
				WepointIndex += 1
				if WepointIndex >= Wepoint.size():
					WepointIndex = 0
				
				currentState = STATE.IDLE
				$Timer.start()
				return 
				
			direction = direction.normalized()
			velocity.x = direction.x * speed



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


func _on_timer_timeout() -> void:
	currentState = STATE.WALK
