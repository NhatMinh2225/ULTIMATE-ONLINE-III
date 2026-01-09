extends Node2D

@onready var choosing_server_overlay: CanvasLayer = $ChoosingServerOverlay
@onready var adventure_music: AudioStreamPlayer = $adventure_music
@onready var music: AudioStreamPlayer = $Music
@onready var ui_top: CanvasLayer = $UI_Top
@onready var whispering: AudioStreamPlayer = $whispering


func _ready():
	music.play()
	# nếu đã chọn server 1 lần rồi → không mở choosing server nữa


	var cursor = load("res://asset/Lords Of Pain - Old School Isometric Assets/user interface/cursor/cursor_gauntlet_green.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(53, 53))


func _show_server_select():
	print("[MAIN] _show_server_select CALLED")
	# tránh spawn lần 2
	if Global.first_server_chosen:
		print("[MAIN] Skipped because first_server_chosen = true")
		return

	var overlay_scene := load("res://Scene/choosing_server_overlay.tscn")
	var overlay = overlay_scene.instantiate()
	add_child(overlay)
	print("[MAIN] Spawning choosing server FIRST TIME")

	# kết nối lần 1
	overlay.connect("play_pressed", Callable(self, "_on_first_time_play"))


func _on_first_time_play(server_name):
	print("First-time choosing server:", server_name)

	# đánh dấu chính thức
	Global.first_server_chosen = true  

	# mở lại input gameplay
	Global.unlock_input()
	
func on_final_button_pressed():
	print("[MAIN] Final pressed received from FinalSequenceController")

	_start_end_timer()

func _start_end_timer():
	print("[MAIN] Waiting 7 seconds before ending game...")

	await get_tree().create_timer(15.0).timeout

	_fade_to_black()  # gọi fade đen

func _fade_to_black():
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)   # bắt đầu trong suốt
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 999999  # ⭐ nằm trên cùng
	ui_top.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)

	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 2.5)  # fade đen sau 2.5 giây

	await tween.finished
	await get_tree().create_timer(3.0).timeout
	$CanvasLayer/Label.show()
	Global.lock_all()


func _on_demonlord_death() -> void:
	await get_tree().create_timer(10).timeout

	whispering.play()
	
