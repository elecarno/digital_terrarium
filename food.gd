extends Area2D

@export var controlled: bool = false

func _physics_process(delta: float):
	if controlled:
		position = get_global_mouse_position()
		
func eat():
	queue_free()
