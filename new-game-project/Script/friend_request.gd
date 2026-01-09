extends CanvasLayer

@onready var label := $Panel/Label
@onready var btn_accept := $Panel/Button_Accept
@onready var btn_decline := $Panel/Button_Decline

func _ready():
	var char_ui = get_tree().root.get_node("Main/Character_UI/Indicator2")
	char_ui.visible = false
	
	label.text = "海斗166 has sent you a friend request."

	btn_accept.pressed.connect(_on_accept_pressed)
	btn_decline.pressed.connect(_on_decline_pressed)


func _on_accept_pressed():
	var char_ui = get_tree().root.get_node("Main/Character_UI")
	char_ui.hide()
	var static_audio = get_tree().root.get_node("Main/StaticAudio")
	if static_audio:
		static_audio.stop()
	
	print("[FRIEND_REQUEST] Accepted → Starting blackout...")
	btn_accept.disabled = true
	btn_decline.disabled = true

	# ----------------------------------
	# 1. Spawn BlackoutOverlay
	# ----------------------------------
	var blackout_path := "res://Scene/blackout_overlay.tscn"
	if not ResourceLoader.exists(blackout_path):
		push_warning("⚠ blackout_overlay.tscn not found!")
		return

	var blackout = load(blackout_path).instantiate()
	get_tree().root.add_child(blackout)

	# ----------------------------------
	# 2. Fade to black for 3 seconds
	# ----------------------------------
	if blackout.has_method("play_and_wait"):
		await blackout.play_and_wait(3.0)
	else:
		print("⚠ BlackoutOverlay missing play_and_wait()")

	# ----------------------------------
	# 3. Open Login UI
	# ----------------------------------
	var login_path := "res://Scene/login_overlay.tscn"
	if ResourceLoader.exists(login_path):
		var login_ui = load(login_path).instantiate()
		get_tree().root.add_child(login_ui)
		print("[FRIEND_REQUEST] Login UI opened.")
	else:
		push_warning("⚠ login_ui.tscn not found!")

	# ----------------------------------
	# 4. Remove friend_request UI
	# ----------------------------------
	queue_free()


func _on_decline_pressed():
	# Decline không làm gì để ép người chơi accept
	print("[FRIEND_REQUEST] Decline pressed (ignored).")
