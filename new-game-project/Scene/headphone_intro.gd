extends CanvasLayer

@onready var control := $ColorRect/Control

const NEXT_SCENE := "res://Scene/main.tscn"
const SHOW_TIME := 2.0

func _ready() -> void:
	_run_sequence()
	

	var cursor = load("res://asset/Lords Of Pain - Old School Isometric Assets/user interface/cursor/cursor_gauntlet_green.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(53, 53))

func _run_sequence() -> void:
	# đặt alpha = 0
	control.modulate.a = 0.0

	# fade in
	var tween_in := create_tween()
	tween_in.tween_property(control, "modulate:a", 1.0, 1.0)
	await tween_in.finished

	# chờ
	await get_tree().create_timer(SHOW_TIME).timeout

	# fade out
	var tween_out := create_tween()
	tween_out.tween_property(control, "modulate:a", 0.0, 1.0)
	await tween_out.finished

	# chuyển scene
	get_tree().change_scene_to_file(NEXT_SCENE)
