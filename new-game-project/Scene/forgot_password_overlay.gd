extends CanvasLayer

@onready var panel := $TextureRect
@onready var question_label := $TextureRect/QuestionLabel
@onready var input_field := $TextureRect/AnswerField
@onready var yes_button := $TextureRect/YesButton
@onready var no_button := $TextureRect/NoButton
@onready var woman_picture: TextureRect = $TextureRect/WomanPicture
@onready var man_picture: TextureRect = $TextureRect/ManPicture
@onready var texture_rect: TextureRect = $TextureRect/TextureRect
@onready var poem: AudioStreamPlayer = $poem
@onready var click: AudioStreamPlayer = $click
@onready var mask: TextureRect = $TextureRect/Mask
@onready var phone_num: Label = $TextureRect/PhoneNum
@onready var adress_home: Label = $TextureRect/AdressHome





signal password_recovered

var stage := 0

func _ready():
	if Global.already_verified:
		_show_result_screen()
		return
	phone_num.visible = false
	yes_button.visible = false
	no_button.visible = false
	mask.visible = false

	
	input_field.text_submitted.connect(_on_text_entered)

	yes_button.pressed.connect(_on_yes_pressed)   # <--- FIX
	no_button.pressed.connect(_on_no_pressed)     # <--- FIX

	panel.modulate = Color(1,1,1,1)
	_fade_in()

	_show_stage()
# =========================
# FADE UTIL
# =========================

func _fade_in():
	var t := create_tween()
	t.tween_property(panel, "modulate", Color(1,1,1,1), 0.25)

func _fade_out():
	var t := create_tween()
	t.tween_property(panel, "modulate", Color(1,1,1,0), 0.25)
	await t.finished

# hiệu ứng đen chuyển stage: fade-out → chờ → fade-in
func _transition_stage():
	click.play()
	Global.lock_input()   # ⬅ khoá input
	yes_button.visible = false
	no_button.visible = false
	panel.modulate = Color(0, 0, 0, 1)
	if stage == 0 or stage == 1 or stage == 2:
		await get_tree().create_timer(2.0).timeout
	if stage == 3 or stage == 4 or stage ==5 or stage == 6 or stage == 7 :
		await get_tree().create_timer(4.0).timeout
	if stage == 8:
		await get_tree().create_timer(6.0).timeout

	panel.modulate = Color(1, 1, 1, 1)





# =========================
# SHOW STAGE
# =========================
func _show_stage():

	if stage > 0:
		await _transition_stage()

	match stage:
		0:
			question_label.text = "Confirm your name:"
			input_field.visible = true
			yes_button.visible = false
			no_button.visible = false
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = true
			_hide_result()

		1:
			question_label.text = "Confirm your date of birth:"
			$TextureRect/AnswerField.placeholder_text = "mm/dd/yyyy"
			input_field.visible = true
			yes_button.visible = false
			no_button.visible = false
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = true

		2:
			question_label.text = "Is this your recovery phone number?"
			input_field.visible = false
			yes_button.visible = true
			no_button.visible = true
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = false
			phone_num.visible = true 
			
		3:
			question_label.text = "Is this your adress?"
			input_field.visible = false
			yes_button.visible = true
			no_button.visible = true
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = false
			phone_num.visible = false
			adress_home.visible = true
			
		4:
			question_label.text = "Do you know this women?"
			input_field.visible = false
			yes_button.visible = true
			no_button.visible = true
			woman_picture.visible = true
			man_picture.visible = false
			texture_rect.visible = false
			phone_num.visible = false
			adress_home.visible = false
			poem.play()

		5:
			question_label.text = "How many years have you been hiding?"
			$TextureRect/AnswerField.placeholder_text = "yy"
			input_field.visible = true
			yes_button.visible = false
			no_button.visible = false
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = true
			
		6:
			question_label.text = "Is this you?"
			input_field.visible = false
			yes_button.visible = true
			no_button.visible = true
			woman_picture.visible = false
			man_picture.visible = true
			texture_rect.visible = false
		
		7:
			question_label.text = "Do you want to feel eternal pain?"
			input_field.visible = false
			yes_button.visible = false
			no_button.visible = false
			$TextureRect/YesButton3.visible = true
			$TextureRect/YesButton2.visible = true
			woman_picture.visible = false
			man_picture.visible = false
			texture_rect.visible = false
			mask.visible = true
			phone_num
		

		8:
			emit_signal("password_recovered")
			Global.already_verified = true
			poem.stop()
			_show_result_screen()




# ==========================================================
# 				INPUT FIELD (câu hỏi nhập text)
# ==========================================================
func _on_text_entered(text):
	var answer = text.strip_edges()

	match stage:

		# --------- STAGE 0: Name ---------
		0:
			# Tên nào cũng chấp nhận
			stage += 1
			input_field.text = ""
			_show_stage()

		# --------- STAGE 1: DOB ---------
		1:
			if _validate_date(answer):
				stage += 1
				input_field.text = ""
				_show_stage()
			else:
				_error_shake()
		
		5:
			if _validate_year(answer):
				stage += 1
				input_field.text = ""
				_show_stage()
			else:
				_error_shake()


# ==========================================================
# 				YES / NO BUTTONS
# ==========================================================
func _on_yes_pressed():
	match stage:
		# Stage 2: "Do you know this girl?"
		2:
			stage += 1
			_show_stage()
		# Stage 2: "Do you know this girl?"
		3:
			stage += 1
			_show_stage()

		# Stage 3: "Is this you?"
		4:
			stage += 1
			_show_stage()
		
		#stage 4: mask
		6:
			stage += 1
			_show_stage()
		7:
			stage += 1
			_show_stage()

func _on_yes_button_2_pressed() -> void:
	match stage:
		7:
			
			stage += 1
			_show_stage()


func _on_no_pressed():
	match stage:
		
		# Stage 2: "phone number"
		2:
			stage += 1
			_show_stage()
		3:
			stage += 1
			_show_stage()

		# Stage 2 → NO sai, không được qua stage
		4:
			_error_shake()
			return  # ⬅ THÊM DÒNG NÀY

		# Stage 3 → NO sai
		6:
			_error_shake()
			return  # ⬅ THÊM DÒNG NÀY
		# stage 4: mask
		7:
			stage += 1
			_show_stage()


# ==========================================================
# 			HELPER: Date Validation
# ==========================================================
func _validate_year(str: String) -> bool:
	var n := int(str)   # chuyển thành số

	# kiểm tra khoảng 1 < n < 30
	if n > 1 and n < 30:
		return true

	return false


func _validate_date(str: String) -> bool:
	var cleaned := str.replace("-", "/")
	var parts := cleaned.split("/")
	
	if parts.size() != 3:
		return false
	
	var m := int(parts[0])
	var d := int(parts[1])
	var y := int(parts[2])
	
	if y < 1900 or y > 2025:
		return false
	if m < 1 or m > 12:
		return false
	if d < 1 or d > 31:
		return false
	
	return true

# ==========================================================
# 			ERROR FEEDBACK (lắc panel)
# ==========================================================
func _error_shake():
	var tween := create_tween()
	var ox = panel.position.x
	tween.tween_property(panel, "position:x", ox + 8, 0.06)
	tween.tween_property(panel, "position:x", ox - 8, 0.06)
	tween.tween_property(panel, "position:x", ox + 5, 0.05)
	tween.tween_property(panel, "position:x", ox, 0.05)
	

func _show_result_screen():
	# Ẩn UI câu hỏi
	phone_num.visible = false
	question_label.visible = false
	input_field.visible = false
	yes_button.visible = false
	no_button.visible = false
	woman_picture.visible = false

	# Hiện result
	$TextureRect/ResultPanel.visible = true

	

	# Kết nối nút X (chỉ kết nối 1 lần)
	var close_btn = $TextureRect/ResultPanel/CloseButton
	if not close_btn.pressed.is_connected(_on_result_close):
		close_btn.pressed.connect(_on_result_close)

func _hide_result():
	$TextureRect/ResultPanel.visible = false

func _on_result_close():
	emit_signal("password_recovered")
	queue_free()
