extends Node

const DATA_PLAYER = "res://Scripts/DataPlayer.json"

var Inicio := false

var LastScene: PackedScene;
var savePosition : Vector2
var saldo: float = 100
#var _bodyPosition: Vector3 = Vector3.ZERO

func LastPosition(position: Vector2 = Vector2(-1335,-15)):
	savePosition = position;
	print(savePosition)
	return savePosition

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
