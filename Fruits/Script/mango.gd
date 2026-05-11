class_name StaticFruit
extends RigidBody2D

@export var min_break_speed := 300.0

var last_velocity := Vector2.ZERO

func _ready():
	contact_monitor = true
	max_contacts_reported = 10

func _process(delta):
	$Label.text = str(linear_velocity)

func _physics_process(delta):
	last_velocity = linear_velocity

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			if collider.name == "FRom":
				if abs(last_velocity.y) >= min_break_speed:
					queue_free()
