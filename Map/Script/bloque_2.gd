extends Node2D

@export var bloque1: Node2D
@export var radio: float = 80.0        # distancia al centro
@export var velocidad: float = 2.0     # radianes por segundo

var angulo: float = 0.0

func _ready() -> void:
	bloque1 = $"../Bloque 1"
	if bloque1:
		var diff = global_position - bloque1.global_position
		angulo = diff.angle()
		radio = diff.length()

func _process(delta: float) -> void:
	if bloque1:
		angulo += velocidad * delta
		
		# Calcula la posición orbital
		global_position = bloque1.global_position + Vector2(
			cos(angulo) * radio,
			sin(angulo) * radio
		)
		
		# Mira hacia el bloque1
		look_at(bloque1.global_position)
