extends Area2D

var _area
var fill
var collision
var AreaSlot: Vector2 = Vector2.ZERO

func _ready() -> void:
	collision = self.find_child("CollisionShape2D").global_position
	if not area_exited.is_connected(_on_area_exited):
		self.area_exited.connect(_on_area_exited)

	if not self.area_entered.is_connected(_on_area_entered):
		self.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	fill =  AreaSlot != collision

	if _area and _area.has_meta("Take"):
		if _area and fill and _area.get_meta("Take") == false:
			_area.global_position = collision
			AreaSlot = _area.global_position


func _on_area_entered(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		_area = area

func _on_area_exited(area: Area2D) -> void:
	if area and area.has_meta("Item"):
		_area = null
		AreaSlot = Vector2.ZERO
