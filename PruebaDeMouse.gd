extends Node2D

const ITEM_BOOK = preload("uid://blce1yqv3wkhk")
var inventory = Global.get_inventory_to_array()
var take = false;
	
var items;
var _area;
var limit;
var slots

func _ready() -> void:
	slots = $Node.get_children()
	
	if _area and _area.has_node("AnimationPlayer"): 
		_area.get_node("AnimationPlayer").play("IDLE")

	for item in inventory:
		var target_slot_index = int(item["Slot"])
		if target_slot_index < slots.size():
			var slot = slots[target_slot_index]
			
			var alo = ITEM_BOOK.instantiate()
			alo.image = item["Image"]
			alo.Cantidad = item["Cantidad"]
			if alo.has_meta("Index"): alo.set_meta("Index", target_slot_index)
			
			alo.global_position = slot.get_node("CollisionShape2D").global_position
			
			add_child(alo)
		else:
			print("Error: El ítem intenta cargarse en el slot ", target_slot_index, ", pero no existe.")
	#get_tree().quit()

func _process(delta: float) -> void:
	$Area2D.global_position = get_global_mouse_position()

	if _area and Input.is_action_just_pressed("ATTACK") and not take:
		var target_slot = _area.get_meta("Index")
		
		for inv_item in inventory:
			if int(inv_item["Slot"]) == target_slot:
				items = inv_item 
				break
				
		take = true
		_area.set_meta("Take", take)
		
	elif Input.is_action_just_released("ATTACK") and take:
		take = false
		if _area:
			_area.set_meta("Take", take)
			
		if limit:
			limit.queue_free()
			limit = null 

	if take:
		if _area and _area.has_node("AnimationPlayer"): 
			_area.get_node("AnimationPlayer").play("SELECTED")
	else:
		if _area and _area.has_node("AnimationPlayer"): 
			_area.get_node("AnimationPlayer").play("IDLE")

	if take and _area:
		_area.global_position = $Area2D.global_position
	
	update_selected_item()

func update_selected_item():
	if items and items["Image"]: 
		$TextureRect.texture = load(items["Image"])
		$NOmbre.text = str(items["Name"])
		
		if items["Cantidad"] > 1: $Cantidad.text = "Unidades" 
		else: $Cantidad.text = "Unidad"
		
		$Cantidad/Cantidad.text = str( int(items["Cantidad"]) )
		$Estado/Estado.text = str(items["Estado"])
		update_quality(int(items["Calidad"]))

func update_quality(value):
	$Stars/Star.visible = value >= 0
	$Stars/Star2.visible = value >= 1
	$Stars/Star3.visible = value >= 2
	$Stars/Star4.visible = value >= 3
	match value:
		0:
			$Stars.modulate = Color.WHITE
		1:
			$Stars.modulate = Color("#979797")
		2:
			$Stars.modulate = Color("#ff9871")
		3:
			$Stars.modulate = Color("#e9c63e")



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Area2D and area.has_meta("Item") and !take:
		_area = area
		if area.has_node("Selected"):area.get_node("Selected").visible = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is Area2D and area.has_meta("Item") and !take:
		_area = null
		if area.has_node("Selected"):area.get_node("Selected").visible = false



func _on_limit_area_exited(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		limit = area

func _on_limit_area_entered(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		limit = null
	
