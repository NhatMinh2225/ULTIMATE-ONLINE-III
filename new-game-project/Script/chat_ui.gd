extends CanvasLayer

var npc_name := "KaiCenat"
var npc_ref = null
var stage := 0
var dialogue_data := {}
var post_profile := false
@onready var creepy_footstep: AudioStreamPlayer = $"CreepyFootsteps-SoundEffectForEditing-SoundEffectNexus"


# ============================
# CONFIG TRIGGER QUAY ĐẦU
# ============================
var turnback_trigger_stage := 57
var friend_request_stage := 2

var turnback_triggered := false

var pc_mode := true     # true = nhìn PC, false = quay đầu
var final_locked := false
var back_overlay = null
var turnback_ui = null  # giữ reference TurnBackUI
var phase3_started := false
var phase3_started_pc := false


@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer
@onready var chat_log: RichTextLabel = $Panel/ChatLog
@onready var btn_a: Button = $Panel/VBoxContainer/Button_OptionA
@onready var btn_b: Button = $Panel/VBoxContainer/Button_OptionB
@onready var btn_c: Button = $Panel/VBoxContainer/Button_OptionC
@onready var btn_d: Button = $Panel/VBoxContainer/Button_OptionD
@onready var broken_glass: AudioStreamPlayer = $BrokenGlass


func start_conversation(npc_name_: String, npc_ref_, start_stage := 0, post_profile_ := false):
	print("=== START CHAT ===")

	npc_name = npc_name_
	npc_ref = npc_ref_
	post_profile = post_profile_

	var file = FileAccess.open("res://story.json", FileAccess.READ)
	dialogue_data = JSON.parse_string(file.get_as_text())
	file.close()

	_show_stage(start_stage)



func _show_stage(s: int):
	stage = s
	_hide_all_buttons()

	var stages = dialogue_data.get("stages", [])
	if stage < 0 or stage >= stages.size():
		_end_conversation()
		return

	var data = stages[stage]
	print("[CHAT] SHOW_STAGE called with:", s, " / total:", stages.size())

	# ==========================================
	# TRIGGER QUAY ĐẦU TẠI STAGE CẤU HÌNH
	# ==========================================
	if stage == turnback_trigger_stage and not turnback_triggered:
		turnback_triggered = true
		_trigger_turnback()
		return  # dừng chat tại đây

	# ====== NPC TALK ======
	var npc_text = data.get("text", "")
	if npc_text.strip_edges() != "":
		var delay = data.get("time", randf_range(2.0, 4.0))
		await get_tree().create_timer(delay).timeout
		_add_message(npc_text, false)

	# ====== CHOICES ======

	
	var choices = data.get("choices", [])
	if choices.is_empty() and data.has("next"):
		var next_stage = data["next"]
		_show_stage(next_stage)
		return
	# Nếu không có lựa chọn → tự động sang stage tiếp theo
	if choices.is_empty() :
		var next_stage := stage + 1
		await get_tree().create_timer(1.0).timeout  # delay nhẹ
		_show_stage(next_stage)
		return

	var texts = []
	for c in choices:
		texts.append(c.get("text", ""))
	_show_choices(texts)



func _add_message(message: String, is_player: bool = false):
	var max_lines := 25

	var formatted := ""
	if is_player:
		formatted = "[color=red][𝕷𝖊𝖌𝖊𝖓𝖉][color=green][Challengerz]:[color=white] %s" % message
	else:
		formatted = "[color=yellow][%s]:[/color] %s" % [npc_name, message]

	var lines = chat_log.text.split("\n")
	lines.append(formatted)

	if lines.size() > max_lines:
		lines = lines.slice(lines.size() - max_lines, lines.size())

	chat_log.text = "\n".join(lines)

	await get_tree().process_frame
	chat_log.scroll_to_line(chat_log.get_line_count() - 1)



func _show_choices(options: Array):
	var buttons = [btn_a, btn_b, btn_c, btn_d]
	for i in range(buttons.size()):
		buttons[i].visible = i < options.size()
		if i < options.size():
			buttons[i].text = options[i]



func _hide_all_buttons():
	for b in [btn_a, btn_b, btn_c, btn_d]:
		b.visible = false



func _process_choice(index: int):


	var stages = dialogue_data.get("stages", [])
	var choices = stages[stage].get("choices", [])

	var display = choices[index].get("text", "")
	var reply = choices[index].get("reply", display)

	_add_message(reply, true)


	var next_stage = choices[index].get("next", stage + 1)

	if next_stage == -1:
		_end_conversation()
	else:
		_show_stage(next_stage)



func _end_conversation():
	print("=== END CHAT ===")

	if post_profile:
		fade_in_audio(creepy_footstep, 10.0, -7)
	else :
		await get_tree().create_timer(2.0).timeout
		var fp = load("res://Scene/friend_request.tscn").instantiate()
		get_tree().root.add_child(fp)
	hide()
	




func _on_button_option_a_pressed(): _process_choice(0)
func _on_button_option_b_pressed(): _process_choice(1)
func _on_button_option_c_pressed(): _process_choice(2)
func _on_button_option_d_pressed(): _process_choice(3)


# ==========================================================
# 🔥 TRIGGER QUAY ĐẦU
# ==========================================================
func _trigger_turnback():
	print("[CHAT] Trigger quay đầu tại stage:", stage)

	_hide_all_buttons()
	Global.lock_input()

	broken_glass.play()

	await get_tree().create_timer(1).timeout  # chờ âm thanh xong

	_spawn_turnback_ui()



func _spawn_turnback_ui():
	var path = "res://Scene/turn_back_ui.tscn"
	turnback_ui = load(path).instantiate()
	get_tree().root.add_child(turnback_ui)

	turnback_ui.connect("turned_to_pc", Callable(self, "_on_back_to_pc"))
	turnback_ui.connect("turned_back", Callable(self, "_on_turned_back"))



# ==========================================================
# CALLBACK – PLAYER QUAY LẠI PC / QUAY RA SAU
# ==========================================================
func _on_back_to_pc():
	

	pc_mode = true
	print("[CHAT] Player quay lại nhìn PC")

	if not phase3_started:
		phase3_started = true
		_start_phase3_timer()
		_show_stage(58)
	else:
		print("[CHAT] Phase 3 đã chạy → không restart timer")



func _on_turned_back():
	pc_mode = false
	print("[CHAT] Player quay ra sau")
	if (final_locked):
		print("[CHAT] PC LOCKED → không được quay lại nữa.")
		v_box_container.hide()
		chat_log.hide()
		turnback_ui.overlay.hide_overlay()
		turnback_ui.disable_return_button()
		_spawn_final_sequence()


# ==========================================================
# 🔥 PHASE 3 – COUNTDOWN 10 GIÂY (TỐI GIẢN)
# ==========================================================
func _start_phase3_timer():
	print("[CHAT] Bắt đầu đếm 10 giây…")

	await get_tree().create_timer(10).timeout

	print("[CHAT] Hết giờ → kiểm tra player")
	
	final_locked = true
	
	if not pc_mode:
		print("[CHAT] Player đang nhìn sau → LOCKED")
		turnback_ui.disable_return_button()
		turnback_ui.overlay.hide_overlay()
		_spawn_final_sequence()
	# Player đang quay ra sau → KHÓA PC


		
var final_sequence_spawned := false

func _spawn_final_sequence():
	if final_sequence_spawned:
		return
	final_sequence_spawned = true
	$".".hide()
	print("[CHAT] final sequences")
	
	Global.final_chat_log = chat_log.text
	Global.final_npc_name = npc_name

	var fs = load("res://Scene/final_sequence_controller.tscn").instantiate()
	get_tree().root.add_child(fs)

func fade_in_audio(audio: AudioStreamPlayer, duration := 15.0, finalAudio := -16):
	audio.volume_db = -40   # bắt đầu gần như im lặng
	audio.play()

	var tween = create_tween()
	tween.tween_property(audio, "volume_db", finalAudio, duration)
