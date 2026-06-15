extends StaticFruit

var item: String = "20"

func _ready():
	print(DataManager.item_database[item])

func data():
	if DataManager.item_database.has(item):
		return {
			"Nombre": DataManager.item_database[item].nombre,
			"Tipo": DataManager.item_database[item].tipo_epoca,
			"Tiempo_crecimiento": DataManager.item_database[item].tiempo_crecimiento,
			"Estado": "Fresco",
			"Calidad": 3,
			"Descripcion": DataManager.item_database[item].descripcion,
			"Precio_Base": DataManager.item_database[item].precio,
			"Image": DataManager.item_database[item].sprite_path,
		}
