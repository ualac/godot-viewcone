extends Spatial

func _process(delta: float) -> void:
	if Input.is_key_pressed( KEY_SPACE ):
		rotate_y(1*delta)


