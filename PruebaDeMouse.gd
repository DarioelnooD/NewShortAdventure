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

	if _area and Input.is_action_just_pressed("ATTACK"):
		var target_slot = _area.get_meta("Index")
		
		for inv_item in inventory:
			if int(inv_item["Slot"]) == target_slot:
				items = inv_item 
				break
				
		take = !take
		_area.set_meta("Take", take)
	
	if take:
		if _area and _area.has_node("AnimationPlayer"): _area.get_node("AnimationPlayer").play("SELECTED")
		
	else:
		if _area and _area.has_node("AnimationPlayer"): _area.get_node("AnimationPlayer").play("IDLE")

	if limit and Input.is_action_just_pressed("ATTACK"):
		limit.queue_free()
		take = false

	if take and _area :
		_area.global_position = $Area2D.global_position
	elif !take and _area:
		_area.global_position = _area.global_position
	
	update_selected_item()


func update_selected_item():
	if items and items["Image"]: 
		$TextureRect.texture = load(items["Image"])



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
	
