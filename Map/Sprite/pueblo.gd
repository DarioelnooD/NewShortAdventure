extends Node2D

var _Body: CharacterBody2D


func _ready() -> void:
	#var url: String = "https://localhost:7198/api/GetItem"
	#
	#var opciones_tls = TLSOptions.client_unsafe()
		#
	#var error: Error = http_request.request(url, PackedStringArray(), HTTPClient.METHOD_GET, "")
	#
	#if error != OK:
		#print("Ocurrió un error al iniciar la petición HTTP.")

	if has_node("PLayerCutOut"):
		_Body = $PLayerCutOut as CharacterBody2D
	elif has_node("PlayerCut"):
		_Body = get_node("PlayerCut") as CharacterBody2D

	if _Body:
		var post = Global.get_last_position_in_door('pueblo')
		if post != null:
			_Body.position = Vector2(post["x"], post["y"])


func _on_forest_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.put_last_position_in_door("pueblo", body.position.x + 5, body.position.y)
		get_tree().change_scene_to_file("res://Map/Scene/forest.tscn")

#
#func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	#if response_code == 200:
		#var json: JSON = JSON.new()
		#var parse_result: Error = json.parse(body.get_string_from_utf8())
		#
		#if parse_result == OK:
			#var response_data = json.get_data()
			#print("¡Datos recibidos con éxito!")
			#print(response_data) # Aquí ya puedes usar los datos devueltos por tu API
		#else:
			#print("Error al parsear el JSON.")
	#else:
		#print("Error en la petición. Código de respuesta: ", response_code)
