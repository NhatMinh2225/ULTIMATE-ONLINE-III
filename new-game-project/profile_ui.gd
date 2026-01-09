extends CanvasLayer

signal profile_closed

@onready var btn_close: Button = $Panel/TextureRect/Button_Close
@onready var npc_image: TextureRect = $Panel/TextureRect

func _ready():
	btn_close.text = "X"
	btn_close.pressed.connect(_on_close_pressed)

	var texture = load("res://assets/npc_cursed.png")
	if texture:
		npc_image.texture = texture

func _on_close_pressed():
	print("[PROFILE_UI] Closed → emit profile_closed")
	emit_signal("profile_closed")
	queue_free()
