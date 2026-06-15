extends Node

var filePath = "res://Scripts/ShopItems.json"
var item_database = {}

func ReadFile():
	if FileAccess.file_exists(filePath):
		var file = FileAccess.open(filePath, FileAccess.READ)
		var content = file.get_as_text();
		file.close()
		var json = JSON.parse_string(content)
		return json

func _ready():
	load_csv_data("res://Scripts/DialogosNpc.csv")

func load_csv_data(file_path: String):
	if not FileAccess.file_exists(file_path):
		print("El archivo no existe en la ruta: ", file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var primera_linea = file.get_csv_line()
	var encabezados = file.get_csv_line()

	while !file.eof_reached():
		var linea = file.get_csv_line()
		
		if linea.size() < 5 or linea[0] == "":
			continue
		
		var item_id = linea[0].strip_edges()
		var item_data = {
			"id": linea[0].strip_edges(),
			"nombre": linea[1].strip_edges(),
			"tipo_epoca": linea[2].strip_edges(),
			"tiempo_crecimiento": int(linea[3].strip_edges()),
			"descripcion": linea[4].strip_edges(),
			"precio": linea[5].strip_edges(),
			"sprite_path": linea[6].strip_edges() if linea.size() > 6 else ""
		}
		
		item_database[item_id] = item_data

	file.close()
	#print("Base de datos de ítems cargada con éxito. Total: ", item_database.size())
