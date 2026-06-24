extends StaticFruit

var item: String = "20"
var object;

func _ready():
	object = DataManager.load_csv_data("res://Scripts/PriceFruit.csv")
	# print(DataManager.item_database[item])

func data():
	if object.has(item):
		return {
			"Nombre": object[item].Nombre,
			"Tipo": object[item].Tipo,
			"Tiempo_crecimiento": object[item].TiempoCreciento_dias,
			"Estado": "Fresco",
			"Calidad": 3,
			"Descripcion": object[item].Descripcion,
			"Precio_Base": int(object[item].Precio_Base),
			"Image": object[item].SPRITE
		}
