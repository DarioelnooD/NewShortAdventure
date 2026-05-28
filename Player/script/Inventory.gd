extends Control

@onready var grid = $GridContainer

func _ready():
	grid.columns = 3
	# limpia slots viejos
	for child in grid.get_children():
		child.queue_free()
	# crea slots del 0 al 8
	for i in range(9):
		var slot = Panel.new()
		# tamaño del slot
		slot.custom_minimum_size = Vector2(64, 64)
		# texto del slot
		var label = Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(label)
		grid.add_child(slot)
