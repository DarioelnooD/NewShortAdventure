extends Area2D
var selec : int = 0
#const SHOP_ITEMS = preload("res://Scripts/ShopItems.json")
const H_BOX = preload("uid://bgo5mn6e4onr2")
var Prepage = 0
var Postpage = 5

func _ready():
	$Control.visible = false

func _process(delta: float) -> void:
	seleccionar(selec)

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
		procesar_compra()

func procesar_compra():
	var item_index = Prepage + selec - 1
	var items = DataManager.read_file()
	
	if item_index < items.size():
		var precio = items[item_index]["Precio"]
		var stock = items[item_index]["Stock"]
		
		if stock > 0 and Global.saldo >= precio:
			Global.saldo -= precio
			Global.save_inventory(items[item_index]["Nombre"],1,'N/a','1',items[item_index]["Image"])
			items[item_index]["Stock"] -= 1
			
			DataManager.save_file(items) 
			
			refresh_menu()
		else:
			print("No hay suficiente saldo o el ítem está agotado.")

func refresh_menu():
	for node in $Control/VBoxContainer.get_children():
		node.queue_free()
		
	var paginator = 1
	var fila_index = 1
	
	for item in DataManager.read_file():
		if paginator > Prepage and paginator <= Postpage:
			var row = H_BOX.instantiate()
			row.get_node("ColorRect").color = _color_for_calidad(item["Calidad"])
			row.get_node("Name").text = str(item["Nombre"], " ", item["Precio"]) 
			row.get_node("value").text = str("$ ", item["Precio"])
			row.get_node("Stock").text = str(item["Stock"])
			$Control/VBoxContainer.add_child(row)

			var captured_index = fila_index

			row.mouse_entered.connect(func():
				selec = captured_index
			)

			row.gui_input.connect(func(event):
				if event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT \
				and event.pressed:
					selec = captured_index
					procesar_compra() 
			)
			# ────────────────────────────────────────────────────
			fila_index += 1
		paginator += 1
