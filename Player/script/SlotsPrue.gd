extends Area2D

var _area: Area2D = null
var collision: Vector2
@export var slot_id: String = "0x0"

func _ready() -> void:
	# ELIMINAMOS la variable collision de aquí
	if not area_exited.is_connected(_on_area_exited):
		self.area_exited.connect(_on_area_exited)
	if not area_entered.is_connected(_on_area_entered):
		self.area_entered.connect(_on_area_entered)

func _process(_delta: float) -> void:
	if _area and _area.has_meta("Take") and self.has_meta("Free"):
		var is_taken = _area.get_meta("Take")
		var is_free = self.get_meta("Free")

		if not is_taken:
			if is_free:
				# 1. OBTENEMOS LA POSICIÓN EN ESTE EXACTO MOMENTO
				var current_pos = self.find_child("CollisionShape2D").global_position
				
				# 2. APLICAMOS LA POSICIÓN ACTUALIZADA AL ÍTEM
				_area.global_position = current_pos
				self.set_meta("Free", false)
				_area.set_meta("LastValidPos", current_pos)
				
				var item_name = ""
				if _area.has_meta("Name"):
					item_name = _area.get_meta("Name")
					
				var target_slot_id = self.name 
				
				Global.change_slot_inventory(item_name, target_slot_id)
			else:
				if _area.has_meta("LastValidPos"):
					_area.global_position = _area.get_meta("LastValidPos")

func _on_area_entered(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		_area = area

func _on_area_exited(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		if _area == area:
			_area = null
			self.set_meta("Free", true)
