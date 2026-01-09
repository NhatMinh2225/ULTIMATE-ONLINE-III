extends CanvasLayer

@onready var panel_bg := $PanelBG
@onready var select_btn := $PanelBG/SelectServerButton
@onready var play_btn := $PanelBG/PlayButton
@onready var server_panel := $PanelBG/ServerPanel
@onready var server_btn := $PanelBG/ServerPanel/ServerButton
@onready var close_server_panel := $PanelBG/ServerPanel/CloseServerPanel
@onready var label: Label = $PanelBG/SelectServerButton/Label
@onready var label2: Label = $PanelBG/ServerPanel/ServerButton/Label
@onready var click: AudioStreamPlayer = $click



var selected_server = null

signal server_chosen(server_name)
signal play_pressed(server_name)

func _ready():
	print(">>> ChoosingServerOverlay SPAWNED:", self)

	# Ban đầu panel server ẩn
	server_panel.visible = false

	# Disable nút Play cho đến khi chọn server
	play_btn.disabled = true

	# Kết nối sự kiện
	select_btn.pressed.connect(_on_open_server_panel)
	close_server_panel.pressed.connect(_on_close_server_panel)
	server_btn.pressed.connect(_on_select_server)
	play_btn.pressed.connect(_on_play_pressed)


func _on_open_server_panel():
	click.play()
	server_panel.visible = true


func _on_close_server_panel():
	click.play()
	server_panel.visible = false


func _on_select_server():
	click.play()
	selected_server = "SEA-01 / Shrine of Solitude"
	play_btn.disabled = false
	server_panel.visible = false
	label.text = label2.text
	emit_signal("server_chosen", selected_server)



func _on_play_pressed():
	click.play()
	await click.finished
	self.visible = false

	# LẦN 1 → KHÔNG mở chat
	if not Global.first_server_select_done:
		var loading = load("res://Scene/loading_screen.tscn").instantiate()
		get_tree().root.add_child(loading)
		loading.connect("loading_done", Callable(self, "_open_chat_after_loading"))
		Global.first_server_select_done = true
		Global.unlock_input()
		queue_free()
		return

	# LẦN 2 → Loading → ChatUI stage 5
	var loading = load("res://Scene/loading_screen.tscn").instantiate()
	get_tree().root.add_child(loading)
	loading.connect("loading_done", Callable(self, "_open_chat_after_loading"))


func _open_chat_after_loading():
	queue_free()

	var chat_scene = load("res://Scene/chat_ui.tscn").instantiate()
	get_tree().root.add_child(chat_scene)

	# bắt đầu hội thoại stage 5
	chat_scene.start_conversation("CursedSoul_02", self, 30, true)
