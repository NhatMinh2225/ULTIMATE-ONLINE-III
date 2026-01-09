extends TextureButton



func _on_pressed() -> void:
	$"../../../Popup".show_toast("This feature is no longer available.")
