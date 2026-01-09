extends CanvasLayer

signal turned_to_pc     # player quay lại nhìn PC (overlay tắt)
signal turned_back       # player quay ra sau (overlay bật)


@onready var btn_turn := $Button
var overlay: CanvasLayer = null

var is_showing := false

func _ready():
	btn_turn.pressed.connect(_on_turn_pressed)


func _on_turn_pressed():
	if overlay == null:
		var overlay_scene = load("res://Scene/back_overlay.tscn")
		overlay = overlay_scene.instantiate()
		get_tree().root.add_child(overlay)

	is_showing = !is_showing

	if is_showing:
		print("[TURNBACK] Mở overlay")
		overlay.show_overlay()

		emit_signal("turned_back")      # 👈 QUAN TRỌNG
	else:
		print("[TURNBACK] Tắt overlay")
		overlay.hide_overlay()

		emit_signal("turned_to_pc")     # 👈 QUAN TRỌNG



func disable_return_button():
	$Button.disabled = true
	$Button.visible = false

func enable_return_button():
	$Button.disabled = false
	$Button.visible = true
