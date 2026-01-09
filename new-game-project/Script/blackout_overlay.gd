extends CanvasLayer

func play_and_wait(duration: float = 3.0) -> void:
	visible = true
	await get_tree().create_timer(duration).timeout
	visible = false
	queue_free()
