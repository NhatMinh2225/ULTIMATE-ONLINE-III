extends Area2D

@export var npc_name := "海斗166"
@export var npc_level := "[lv2]" 
@export var dialogue_scene: PackedScene
@export var prompt_scene: PackedScene
@onready var name_label: Label = $Label
var prompt_instance = null
var player_in_cutscene := false

func _ready():
	input_pickable = true
	name_label.text = npc_name + npc_level
	name_label.add_theme_font_size_override("font_size", 12)


func _input_event(viewport, event, shape_idx):
	# 🚫 Không cho click nếu gameplay đang bị khóa (ví dụ: đang trong chat)
	if Global.is_locked():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not player_in_cutscene:
			_toggle_prompt()


func _toggle_prompt():
	if prompt_instance:
		_remove_prompt()
	else:
		_show_prompt()


func _show_prompt():
	# Xóa prompt cũ (phòng trường hợp bị double-click)
	_remove_prompt()

	prompt_instance = prompt_scene.instantiate()
	get_tree().root.add_child(prompt_instance)

	# Đặt vị trí prompt phía trên đầu NPC
	prompt_instance.global_position = global_position + Vector2(0, -40)

	# Kết nối tín hiệu từ prompt khi người chơi chọn “Chat”
	prompt_instance.connect("chat_started", Callable(self, "_on_chat_started"))


func _remove_prompt():
	if prompt_instance and is_instance_valid(prompt_instance):
		prompt_instance.queue_free()
	prompt_instance = null


func _on_chat_started():
	_remove_prompt()
	player_in_cutscene = true

	# 🔒 Chỉ khóa input chuột, không dừng di chuyển hiện tại
	Global.lock_input()

	# Đợi 1 frame để đảm bảo mọi di chuyển/animation cập nhật xong
	await get_tree().process_frame

	# Tạo và khởi chạy scene hội thoại
	if dialogue_scene:
		var chat_ui = dialogue_scene.instantiate()
		get_tree().root.add_child(chat_ui)
		chat_ui.start_conversation(npc_name, self)
