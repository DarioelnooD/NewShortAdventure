extends Area2D
var selec : int = 0
const SHOP_ITEMS = preload("res://Scripts/ShopItems.json")
const H_BOX = preload("uid://bgo5mn6e4onr2")
var Prepage = 0
var Postpage = 5

func _ready():
	$Control.visible = false

func _process(delta: float) -> void:
	seleccionar(selec)

func menu():
	$Control.visible = true
	if Input.is_action_just_pressed("Right"):
		Prepage += 5
		Postpage += 5
		refresh_menu()
	if Input.is_action_just_pressed("Left"):
		Prepage -= 5
		Postpage -= 5
		if Prepage < 0:
			Prepage = 0
			Postpage = 5
		refresh_menu()
	if Input.is_action_just_pressed("JUMP"):
		var item_index = Prepage + selec - 1
		var items = DataManager.ReadFile()
		if item_index < items.size():
			Global.saldo -= items[item_index]["Precio"]

func refresh_menu():
	for node in $Control/VBoxContainer.get_children():
		node.queue_free()
	var paginator = 1
	var fila_index = 1  # índice 1..5 para coincidir con selec
	for item in DataManager.ReadFile():
		if paginator > Prepage and paginator <= Postpage:
			var row = H_BOX.instantiate()
			row.get_node("ColorRect").color = _color_for_calidad(item["Calidad"])
			row.get_node("Name").text = str(item["Nombre"], item["Precio"])
			row.get_node("value").text = str("$ ", item["Precio"])
			$Control/VBoxContainer.add_child(row)

			# ── Selección con mouse ──────────────────────────────
			var captured_index = fila_index  # captura para el lambda

			# Hover: resaltar al pasar el mouse
			row.mouse_entered.connect(func():
				selec = captured_index
			)

			# Click: comprar el ítem
			row.gui_input.connect(func(event):
				if event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT \
				and event.pressed:
					selec = captured_index
					var item_index = Prepage + selec - 1
					var items = DataManager.ReadFile()
					if item_index < items.size():
						Global.saldo -= items[item_index]["Precio"]
			)
			# ────────────────────────────────────────────────────

			fila_index += 1
		paginator += 1

func seleccionar(selec):
	for child in $Control/VBoxContainer2.get_children():
		var rect = child.get_node("ColorRect")
		rect.color = Color("ffff0000")
	var selected = get_node_or_null(
		"Control/VBoxContainer2/HBoxContainer%s/ColorRect" % selec
	)
	if selected:
		selected.color = Color("ffff003b")

func selec1():
	if selec < 5:
		selec += 1
	else:
		selec = 1

func selec_1():
	if selec > 1:
		selec -= 1
	else:
		selec = 5

func _color_for_calidad(calidad: String) -> Color:
	match calidad:
		"Común":      return Color("#888780")
		"Raro":       return Color("#378ADD")
		"Épico":      return Color("#7F77DD")
		"Legendario": return Color("#EF9F27")
		_:            return Color.WHITE
