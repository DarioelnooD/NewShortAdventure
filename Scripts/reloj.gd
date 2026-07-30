extends Node
@onready var minuts: Node2D;
@onready var hour: Node2D;

func _ready() -> void:
	minuts = get_node("minuts")
	hour = get_node("Hour")

func _process(delta: float) -> void:
	if minuts: minuts.rotation += 0.1 * delta
	if hour: hour.rotation += 0.0085 * delta
