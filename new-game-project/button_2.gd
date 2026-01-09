extends TextureButton


func _on_pressed() -> void:
	$"../TextureRect".show()
	$".".hide()
