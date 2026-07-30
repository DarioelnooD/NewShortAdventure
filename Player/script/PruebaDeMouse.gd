extends Node2D

@onready var color_rect: ColorRect = $Inventory/LiveBarBoder/ColorRect

@export var live: int = Global.get_live();

const ITEM_BOOK = preload("uid://blce1yqv3wkhk")
var inventory = Global.get_inventory_to_array()
var take = false;

enum State {INVENTORY, SHOP, MAP, CONFIG}
enum STATECONFIG{ GENERAL, VOLUMEN }
var ConfigState: STATECONFIG = STATECONFIG.GENERAL
var BookState: State = State.INVENTORY

var items;
var _area;
var limit;
var slots

func _ready() -> void:
	var slots_parent = self.get_node('Inventory/Node')
	var InventoryNode = self.get_node('Inventory')
	
	if _area and _area.has_node("AnimationPlayer"): 
		_area.get_node("AnimationPlayer").play("IDLE")

	for item in inventory:
		var slot_name = str(item["Slot"]) 
		
		var slot = slots_parent.get_node_or_null(slot_name)
		
		if slot != null:
			var alo = ITEM_BOOK.instantiate()
			alo.image = item["Image"]
			alo.Cantidad = item["Cantidad"]
			
			alo.set_meta("Name", item["Name"])
			
			if alo.has_meta("Index"): 
				alo.set_meta("Index", slot_name)
			
			InventoryNode.add_child(alo)
			
			alo.global_position = slot.get_node("CollisionShape2D").global_position
		else:
			print("Error: El ítem intenta cargarse en el slot '", slot_name, "', pero no existe.")

func _process(delta: float) -> void:
	color_rect.custom_maximum_size.x = live
	#if color_rect.custom_maximum_size.x <= 0:
		#color_rect.custom_maximum_size.x = 40
	#else:
		#color_rect.custom_maximum_size.x -= 1
	$Area2D.global_position = get_global_mouse_position()

	if _area and Input.is_action_just_pressed("ATTACK") and not take:
		var target_slot = str(_area.get_meta("Index"))
		
		for inv_item in inventory:
			if str(inv_item["Slot"]) == target_slot:
				items = inv_item 
				break
				
		take = true
		_area.set_meta("Take", take)
		
	elif Input.is_action_just_released("ATTACK") and take:
		take = false
		if _area:
			_area.set_meta("Take", take)
			
			if limit:
				if _area.has_meta("LastValidPos"):
					_area.global_position = _area.get_meta("LastValidPos")
				limit = null

	if take:
		if _area and _area.has_node("AnimationPlayer"): 
			_area.get_node("AnimationPlayer").play("SELECTED")
	else:
		if _area and _area.has_node("AnimationPlayer"): 
			_area.get_node("AnimationPlayer").play("IDLE")

	if take and _area:
		_area.global_position = $Area2D.global_position
	
	state_machine()
	update_selected_item()

func update_selected_item():
	if items and items["Image"]: 
		$Inventory/TextureRect.texture = load(items["Image"])
		$Inventory/NOmbre.text = str(items["Name"])
		
		if items["Cantidad"] > 1: $Inventory/Cantidad.text = "Unidades" 
		else: $Inventory/Cantidad.text = "Unidad"
		
		$Inventory/Cantidad/Cantidad.text = str( int(items["Cantidad"]) )
		$Inventory/Estado/Estado.text = str(items["Estado"])
		update_quality(int(items["Calidad"]))

func update_quality(value):
	$Inventory/Stars/Star.visible = value >= 0
	$Inventory/Stars/Star2.visible = value >= 1
	$Inventory/Stars/Star3.visible = value >= 2
	$Inventory/Stars/Star4.visible = value >= 3
	match value:
		0:
			$Inventory/Stars.modulate = Color.WHITE
		1:
			$Inventory/Stars.modulate = Color("#979797")
		2:
			$Inventory/Stars.modulate = Color("#ff9871")
		3:
			$Inventory/Stars.modulate = Color("#e9c63e")


func state_machine():
	match BookState:
		State.INVENTORY:
			$PlaceholderAnimationBook.texture = load("res://Imports/StateBook/ArtBookFinish.png")
			$Inventory.visible = true
			$Map.visible = false
			$Settings.visible = false
			$Taks/InventTrip.position = Vector2(992,93) 
			$Taks/ShopTrip.position = Vector2(1031,225)
			$Taks/MapTrip.position = Vector2(1032,174)
			$Taks/ConfigTrip.position = Vector2(1030,528)
		State.SHOP:
			$PlaceholderAnimationBook.texture = load("res://Imports/StateBook/ArtBookShopFinish.png")
			$Inventory.visible = false
			$Map.visible = false
			$Settings.visible = false
			$Taks/InventTrip.position = Vector2(154.745,110.745)
			$Taks/ShopTrip.position = Vector2(1031,225)
			$Taks/MapTrip.position = Vector2(156.15, 176.03)
		State.MAP:
			$PlaceholderAnimationBook.texture = load("res://Imports/StateBook/ArtBookMapFinish.png")
			$Inventory.visible = false
			$Map.visible = true
			$Settings.visible = false
			$Taks/InventTrip.position = Vector2(154.745,110.745)
			$Taks/ShopTrip.position = Vector2(1031,225)
			$Taks/MapTrip.position = Vector2(1032,174)
		State.CONFIG:
			$PlaceholderAnimationBook.texture = load("res://Imports/StateBook/ArtBookConfigFinish.png")
			$Inventory.visible = false
			$Map.visible = false
			$Settings.visible = true
			$Taks/InventTrip.position = Vector2(154.745,73.705)
			$Taks/ShopTrip.position = Vector2(153.725,235.575)
			$Taks/MapTrip.position = Vector2(156.15, 176.03)
			match ConfigState:
				STATECONFIG.GENERAL:
					$Settings/IGeneral.visible = true
					$Settings/IVolumen.visible = false
				STATECONFIG.VOLUMEN:
					$Settings/IGeneral.visible = false
					$Settings/IVolumen.visible = true


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
	


func invent_trip() -> void:
	BookState = State.INVENTORY
func shop_trip() -> void:
	BookState = State.SHOP
func map_trip() -> void:
	BookState = State.MAP
func config_trip() -> void:
	BookState = State.CONFIG


func exit_pressed() -> void:
	get_tree().quit()
func volumen_pressed() -> void:
	ConfigState = STATECONFIG.VOLUMEN
func general_pressed() -> void:
	ConfigState = STATECONFIG.GENERAL


func generalMute() -> void:
	if $Settings/IVolumen/General/VolumenIcon.texture == load("res://Imports/VolumenMuteIcon.png"):
		$Settings/IVolumen/General/VolumenIcon.texture = load("res://Imports/VolumenIcon.png") 
	else:
		$Settings/IVolumen/General/VolumenIcon.texture = load("res://Imports/VolumenMuteIcon.png")
func ambienteMute() -> void:
	if $Settings/IVolumen/Ambiente/VolumenIcon.texture == load("res://Imports/VolumenMuteIcon.png"):
		$Settings/IVolumen/Ambiente/VolumenIcon.texture = load("res://Imports/VolumenIcon.png") 
	else:
		$Settings/IVolumen/Ambiente/VolumenIcon.texture = load("res://Imports/VolumenMuteIcon.png")
