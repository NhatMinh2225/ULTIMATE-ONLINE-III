extends CanvasLayer

@onready var log: RichTextLabel = $Panel/ChatLogFinal

var original_text := ""
var npc_name := ""
var player_name := "KaminariClaw"  # hoặc Global.player_name

func start_reveal(final_data):
	original_text = final_data.text
	npc_name = final_data.npc_name

	print(">>> FINAL NPC NAME:", npc_name)

	_show_reconstructed_chat()


func _show_reconstructed_chat():
	log.clear()

	var lines = original_text.split("\n")

	# ---- Tạo TAG theo NPC thật ----
	var npc_tag = "[color=yellow][%s]:[/color]" % npc_name
	var player_tag = "[color=red][Legends][color=green][%s]:[color=white]" % player_name

	print("NPC TAG TO REPLACE =", npc_tag)

	for l in lines:
		var fixed = l

		if npc_tag in fixed:
			print("FOUND NPC TAG IN:", l)
			fixed = fixed.replace(npc_tag, player_tag)

		log.append_text(fixed + "\n")

	log.scroll_to_line(log.get_line_count() - 1)
