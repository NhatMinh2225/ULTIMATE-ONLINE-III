extends CanvasLayer

signal profile_closed

@onready var btn_close: Button = $Panel/TextureRect/Button_Close

func _ready():
	print("[PROFILE_UI] Ready, trying to find Button_Close...")
	if btn_close:
		print("[PROFILE_UI] ✅ Button_Close found, connecting signal.")
		btn_close.text = "X"
		btn_close.pressed.connect(_on_close_pressed)
	else:
		push_error("[PROFILE_UI] ❌ Không tìm thấy Button_Close — kiểm tra lại node path!")

func _on_close_pressed():
	print("[PROFILE_UI] Button X pressed → emit signal profile_closed ✅")
	emit_signal("profile_closed")
	queue_free()
