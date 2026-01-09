extends CanvasLayer

@onready var panel := $TextureRect
@onready var username_field := $TextureRect/UsernameField
@onready var password_field := $TextureRect/PasswordField
@onready var login_btn := $TextureRect/LoginButton
@onready var forgot_btn := $TextureRect/ForgotPasswordButton
@onready var lost_panel := $TextureRect/LostConnectionPanel
@onready var retry_btn := $TextureRect/LostConnectionPanel/LostLabel/RetryButton

const CORRECT_USERNAME := "Kenta_ito222"
const CORRECT_PASSWORD := "kenta.123"

signal login_success
signal forgot_password_pressed

# ✔ Fade chỉ chạy một lần sau khi Retry được ấn
var retry_faded_in := false


func _ready():

	# Khi mới mở login overlay → MẤT KẾT NỐI → không fade
	$TextureRect.modulate = Color(1,1,1,1)

	# Khóa input game
	Global.lock_input()

	# Kết nối nút
	login_btn.pressed.connect(_on_login_pressed)
	forgot_btn.pressed.connect(_on_forgot_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)

	# LOST CONNECTION:
	lost_panel.visible = true
	lost_panel.modulate = Color(1,1,1,1)

	# Ẩn login UI cho đến khi ấn Retry
	_show_login_ui(false)



# ============================
# ✔ CHỈ FADE-IN SAU KHI RETRY
# ============================
func _run_retry_fade_in():
	if retry_faded_in:
		return  # fade đã từng chạy → không chạy nữa

	retry_faded_in = true

	# Bước 1: ĐEN TOÀN MÀN HÌNH
	panel.modulate = Color(0,0,0,1)

	await get_tree().create_timer(5.0).timeout  # giữ đen 2 giây

	# Bước 2: Fade-in login UI
	panel.modulate = Color(1,1,1,0)

	var tween := create_tween()
	tween.tween_property(panel, "modulate", Color(1,1,1,1), 0.4)


# ============================
# XỬ LÝ LOGIN
# ============================
func _on_login_pressed():
	var user = username_field.text.strip_edges()
	var password_input = password_field.text.strip_edges()
	
	if user == CORRECT_USERNAME and password_input == CORRECT_PASSWORD:
		emit_signal("login_success")
		_show_server_overlay_second_time()
	else:
		_show_error_feedback()


func _show_error_feedback():
	var tween := create_tween()
	var original_x = panel.position.x

	tween.tween_property(panel, "position:x", original_x + 8, 0.06)
	tween.tween_property(panel, "position:x", original_x - 8, 0.06)
	tween.tween_property(panel, "position:x", original_x + 5, 0.05)
	tween.tween_property(panel, "position:x", original_x, 0.05)



# ============================
# FORGOT PASSWORD
# ============================
func _on_forgot_pressed():
	emit_signal("forgot_password_pressed")

	var fp_path := "res://Scene/forgot_password_overlay.tscn"
	if ResourceLoader.exists(fp_path):
		var fp_ui = load(fp_path).instantiate()
		get_tree().root.add_child(fp_ui)
	else:
		push_warning("⚠ forgot_password_overlay.tscn NOT FOUND")


# ============================
# RETRY → BLACKOUT → LOGIN
# ============================
func _on_retry_pressed():

	# 1. Ẩn Lost Connection
	lost_panel.visible = false

	# 2. Đen + Fade-in một lần duy nhất
	await _run_retry_fade_in()

	# 3. Hiện login UI
	_show_login_ui(true)



func _show_login_ui(state: bool):
	username_field.visible = state
	password_field.visible = state
	login_btn.visible = state
	forgot_btn.visible = state


func _close_overlay():
	queue_free()
	
func _show_server_overlay_second_time():
	print("[LOGIN] _show_server_overlay_second_time CALLED")
	var scene_path = "res://Scene/choosing_server_overlay.tscn"
	if ResourceLoader.exists(scene_path):
		var overlay = load(scene_path).instantiate()
		get_tree().root.add_child(overlay)



		overlay.connect("play_pressed", Callable(self, "_on_second_time_play"))
	else:
		push_warning("⚠ choosing_server_overlay.tscn NOT FOUND")

	# Ẩn login overlay — nhưng không queue_free ngay để tránh crash tín hiệu
	self.visible = false

func _on_second_time_play(server_name):
	print("Second-time server confirmed:", server_name)

	# Ẩn overlay login luôn
	queue_free()


	# Bây giờ player và NPC vẫn đứng ở đó và có thể mở đoạn hội thoại tiếp theo
