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
	#match selec:
		#0:
			#$Control/VBoxContainer2/HBoxContainer/ColorRect.color = "ffff003b"
			#$Control/VBoxContainer2/HBoxContainer2/ColorRect.color = "ffff0000"
		#1: 
			#$Control/VBoxContainer2/HBoxContainer/ColorRect.color = "ffff0000"
			#$Control/VBoxContainer2/HBoxContainer2/ColorRect.color = "ffff003b"
		#_: selec = 0

func menu():
	$Control.visible = true
	if Input.is_action_just_pressed("ui_right"):
		Prepage += 5
		Postpage += 5
		#var items = $Control/VBoxContainer.get_children()
#
		#if Postpage >= items.size():
			#Prepage = items.size() - 5
			#Postpage = items.size()

		refresh_menu()
	if Input.is_action_just_pressed("ui_left"):
		Prepage -= 5
		Postpage -= 5

		if Prepage < 0:
			Prepage = 0
			Postpage = 5

		refresh_menu()
	if Input.is_action_just_pressed("JUMP"):
		Global.saldo -= DataManager.ReadFile()[0]["Precio"] 

func refresh_menu():
	for node in $Control/VBoxContainer.get_children():
		node.queue_free()
	var paginator = 1
	for item in DataManager.ReadFile():

		if paginator > Prepage and paginator <= Postpage:

			var row = H_BOX.instantiate()

			row.get_node("ColorRect").color = _color_for_calidad(item["Calidad"])
			row.get_node("Label").text = str(item["Nombre"], item["Precio"])

			$Control/VBoxContainer.add_child(row)

		paginator += 1

func seleccionar(selec):
	for child in $Control/VBoxContainer2.get_children():
		var rect = child.get_node("ColorRect")
		rect.color = Color("ffff0000") # color normal

	var selected = get_node_or_null(
		"Control/VBoxContainer2/HBoxContainer%s/ColorRect" % selec
	)

	if selected:
		selected.color = Color("ffff003b") # color seleccionado

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
		"Común":     return Color("#888780")
		"Raro":      return Color("#378ADD")
		"Épico":     return Color("#7F77DD")
		"Legendario": return Color("#EF9F27")
		_:           return Color.WHITE
