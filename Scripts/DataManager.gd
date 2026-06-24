extends Node

var file_path = "res://Scripts/ShopItems.json"

func read_file():
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text();
		file.close()
		var json = JSON.parse_string(content)
		return json
		
func save_file(data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(data, "\t")
		
		file.store_string(json_string)
		
		file.close()
		print("Archivo JSON guardado con éxito.")
	else:
		print("Error al intentar guardar el archivo. Código de error: ", FileAccess.get_open_error())

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar_juego()

func load_csv_data(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("El archivo no existe en la ruta: ", file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("No se pudo abrir el archivo: ", file_path)
		return {}
	
	# Leer las dos primeras líneas (título y encabezados)
	var primera_linea = file.get_csv_line()
	var encabezados = file.get_csv_line()
	
	var item_database = {}
	
	while not file.eof_reached():
		var linea = file.get_csv_line()
		if linea.size() < encabezados.size() or linea[0].strip_edges() == "":
			continue
		var item_id = linea[0].strip_edges()
		var item_data = {}
		# Mapear cada columna con su encabezado correspondiente
		for i in range(min(encabezados.size(), linea.size())):
			var clave = encabezados[i].strip_edges()
			var valor = linea[i].strip_edges()
			item_data[clave] = valor
		item_database[item_id] = item_data
	file.close()
	print("Base de datos cargada. Total ítems: ", item_database.size())
	return item_database

func guardar_juego():
	var scene_path := ""

	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path

	var data = {
		"ultima_escena": scene_path
	}

	var file = FileAccess.open("user://DataPlayer.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
