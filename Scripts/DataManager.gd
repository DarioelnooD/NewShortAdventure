extends Node

var filePath = "res://Scripts/ShopItems.json"

func ReadFile():
	if FileAccess.file_exists(filePath):
		var file = FileAccess.open(filePath, FileAccess.READ)
		var content = file.get_as_text();
		file.close()
		var json = JSON.parse_string(content)
		return json
