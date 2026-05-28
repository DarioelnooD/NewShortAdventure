extends Node

const DATA_PLAYER = "res://Scripts/DataPlayer.json"

var inicio := false

var last_scene: PackedScene;
var save_position : Vector2
var saldo: float = get_saldo()

func get_saldo():
	if FileAccess.file_exists(DATA_PLAYER):
		var file = FileAccess.open(DATA_PLAYER, FileAccess.READ)
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		return data["Saldo"]

func get_live():
	if FileAccess.file_exists(DATA_PLAYER):
		var file = FileAccess.open(DATA_PLAYER, FileAccess.READ)
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		return data["Vida"]


func get_last_position_in_door(name = ''):
	if FileAccess.file_exists(DATA_PLAYER):
		var file = FileAccess.open(DATA_PLAYER, FileAccess.READ)
		var content = file.get_as_text()
		
		var data = JSON.parse_string(content)
		if name != '':
			if data.has("Position"):
				for item in data["Position"]:
					if item["name"] == name:
						return item
		else:
			return data

func put_last_position_in_door(name = "", x = 0, y = 0):
	var data = get_last_position_in_door()
	if name != "" and x != 0 and y != 0:
		if !data.has("Position"):
			data["Position"] = []
		var exist = false
		for i in range(data["Position"].size()):
			if data["Position"][i]["name"] == name:
				data["Position"][i]["x"] = x
				data["Position"][i]["y"] = y
				exist = true
				break
		# SI NO EXISTE LO CREA
		if !exist:
			data["Position"].append({
				"name": name,
				"x": x,
				"y": y
			})
	var file_write = FileAccess.open(DATA_PLAYER, FileAccess.WRITE)
	file_write.store_string(JSON.stringify(data))
	print(data)

func save_inventory(name = "", cantidad = 0, estado = "", calidad = 0):
	var data = get_last_position_in_door()
	if name == "" or cantidad <= 0:
		return
	if !data.has("Inventary"):
		data["Inventary"] = []
	var exist = false
	for i in range(data["Inventary"].size()):
		var item = data["Inventary"][i]
		if  item["Name"] == clear_name(name) and item["Calidad"] == calidad:
			item["Cantidad"] += cantidad
			item["Estado"] = estado
			exist = true
			break
	if !exist:
		var used_slots = []
		for item in data["Inventary"]:
			used_slots.append(item["Slot"])
		var new_slot = ""
		for row in range(4):
			for col in range(4):
				var slot_name = str(row) + "x" + str(col)
				if !used_slots.has(slot_name):
					new_slot = slot_name
					break
			if new_slot != "":
				break
		data["Inventary"].append({
			"Name": name,
			"Cantidad": cantidad,
			"Estado": estado,
			"Calidad": calidad,
			"Slot": new_slot
		})
	var file_write = FileAccess.open(DATA_PLAYER, FileAccess.WRITE)
	file_write.store_string(JSON.stringify(data))

func get_inventory_to_array(name = ''):
	if FileAccess.file_exists(DATA_PLAYER):
		var file = FileAccess.open(DATA_PLAYER, FileAccess.READ)
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if data.has("Inventary"):
			if name != '':
				for item in data["Inventary"]:
					if item["name"] == name:
						return item
			return data["Inventary"]
	return []

func clear_name(text:String) -> String:
	var result = ""
	for c in text:
		if not c.is_valid_int():
			result += c
	return result
