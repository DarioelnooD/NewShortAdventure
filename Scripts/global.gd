extends Node

const DATA_PLAYER = "res://Scripts/DataPlayer.json"

var Inicio := false

var LastScene: PackedScene;
var savePosition : Vector2
var saldo: float = GetSalgo()
#var _bodyPosition: Vector3 = Vector3.ZERO

#func LastPosition(position: Vector2 = Vector2(-1335,-15)):
	#savePosition = position;
	#print(savePosition)
	#return savePosition

func GetSalgo():
	if FileAccess.file_exists(DATA_PLAYER):
		var file = FileAccess.open(DATA_PLAYER, FileAccess.READ)
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		return data["Saldo"]


func GetLastPositionInDoor(name = ''):
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


func PutLastPositionInDoor(name = "", x = 0, y = 0):
	var data = GetLastPositionInDoor()
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

#"Inventary":[
		#{
			#"Name":"Mango",
			#"Cantidad":0,
			#"Estado":"fresco",
			#"Calidad":"Hierro",
			#"Slot":"0"
		#}
func SaveInventory(Name = "", Cantidad = 0, Estado = "", Calidad = 0):
	var data = GetLastPositionInDoor()
	if Name == "" or Cantidad <= 0:
		return
	if !data.has("Inventary"):
		data["Inventary"] = []
	var exist = false
	for i in range(data["Inventary"].size()):
		var item = data["Inventary"][i]
		if item["Name"] == Name and item["Calidad"] == Calidad:
			item["Cantidad"] += Cantidad
			item["Estado"] = Estado
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
			"Name": Name,
			"Cantidad": Cantidad,
			"Estado": Estado,
			"Calidad": Calidad,
			"Slot": new_slot
		})
	var file_write = FileAccess.open(DATA_PLAYER, FileAccess.WRITE)
	file_write.store_string(JSON.stringify(data))

func GetInventorytoArray(name = ''):
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

#func lastPositionCheck():
	#var data = GetLastPositionInDoor()
	#if data["LastScene"]:
		#return data["LastScene"]
	#else:
		#return get_tree().current_scene.scene_file_path

#func SaveCurrentScene():
	#var current_path = get_tree().current_scene.scene_file_path
	#var data = GetLastPositionInDoor()
	#data["LastScene"] = current_path
	#var file = FileAccess.open(DATA_PLAYER, FileAccess.WRITE)
	#file.store_string(JSON.stringify(data))
	#file.close()
