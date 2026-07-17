extends Area2D

@export var image = ''
@export var Cantidad = 0

func _ready() -> void:
	if image != '':
		$TextureRect.texture = load(image)
	if Cantidad:
		$Label.text = str(int(Cantidad))
