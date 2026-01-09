extends Button

signal final_pressed
func _on_pressed() -> void:
	emit_signal("final_pressed")
	await get_tree().process_frame
	$"..".hide()
	var npc = get_tree().root.get_node("Main/npc")
	npc.hide()

	Global.unlock_all()
	_show_final_chat_twist()
	
func _show_final_chat_twist():
	var final_scene = load("res://Scene/chat_ui_final.tscn").instantiate()
	get_tree().root.add_child(final_scene)

	# Lấy chat log từ ChatUI cũ
	var chat_ui = get_tree().root.get_node_or_null("ChatUI")
	var old_text := ""
	if chat_ui:
		old_text = chat_ui.chat_log.text

	final_scene.start_reveal({
		"text": Global.final_chat_log,
		"npc_name": Global.final_npc_name
	})
	print("DEBUG FINAL LOG:", Global.final_chat_log)
