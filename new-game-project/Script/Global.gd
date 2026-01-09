extends Node

# Trạng thái khóa tách biệt
var input_locked := false
var movement_locked := false
var chat_locked := false
var global_freeze := false  # Dùng cho lock toàn game
var already_verified := false
var server_select_first_time := true
var first_server_select_done := false
var first_server_chosen := false
var first_loading_screen := false
var first_chat_done := false
var player_name := "KaminariClaw"   # hoặc tên bạn muốn
var final_npc_name := ""
var final_chat_log := ""

# 🔒 Khóa input
func lock_input():
	input_locked = true
	print("[Global] Input locked")

# 🔓 Mở input
func unlock_input():
	input_locked = false
	print("[Global] Input unlocked")

# 🔒 Khóa di chuyển
func lock_movement():
	movement_locked = true
	print("[Global] Movement locked")

# 🔓 Mở di chuyển
func unlock_movement():
	movement_locked = false
	print("[Global] Movement unlocked")

# 🔒 Khóa chat
func lock_chat():
	chat_locked = true
	print("[Global] Chat locked")

# 🔓 Mở chat
func unlock_chat():
	chat_locked = false
	print("[Global] Chat unlocked")

# 🔒 Đóng băng toàn bộ gameplay
func lock_all():
	input_locked = true
	movement_locked = true
	chat_locked = true
	global_freeze = true
	print("[Global] Gameplay fully locked")

# 🔓 Mở tất cả
func unlock_all():
	input_locked = false
	movement_locked = false
	chat_locked = false
	global_freeze = false
	print("[Global] Gameplay fully unlocked")

# 🔒 Lock input, chờ đến khi player đi hết rồi mới lock movement
func lock_input_then_movement():
	lock_input()
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("is_moving"):
		while player.is_moving():  # chờ đến khi player thực sự dừng
			await get_tree().process_frame
	lock_movement()
	print("[Global] Movement locked after player stopped")

# ✅ Kiểm tra trạng thái
func is_input_locked() -> bool:
	return input_locked or global_freeze

func is_movement_locked() -> bool:
	return movement_locked or global_freeze

func is_chat_locked() -> bool:
	return chat_locked or global_freeze

func is_locked() -> bool:
	return input_locked or movement_locked or chat_locked or global_freeze
