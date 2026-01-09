extends CanvasLayer

signal loading_done

@onready var texture_progress_bar: TextureProgressBar = $PanelBG/TextureRect3/TextureProgressBar

func _ready():
	Global.lock_input()
	self.visible = true
	_start_fake_loading()


func _start_fake_loading():
	var seconds := 6.0
	var char_ui = get_tree().root.get_node("Main/Character_UI")
	char_ui.hide()
	if Global.first_loading_screen:
		$PanelBG/Label2/Label3.text = "█̵̨͜w̵̛h̶͘ỳ̷̢ ̢̢͡a̴͢͡r̨̧̀e̷̕ ̴̴ý̀ơ͢͢u̸͘ ̵̛s̸͏t̵͠i͏̧l̵̛̛l̴̡͜ ̸͘h͘͝e̴̷r̨̛e̛͝?̡"

	var elapsed := 0.0

	# chạy progress bar trong đúng khoảng seconds
	while elapsed < seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		texture_progress_bar.value = (elapsed / seconds) * 100

	# đảm bảo full 100%
	texture_progress_bar.value = 100
	await get_tree().create_timer(2).timeout
	emit_signal("loading_done")
	char_ui.show()
	if not Global.first_loading_screen:
		Global.first_loading_screen = true
		var music = get_tree().root.get_node("Main/Music")
		music.stop()
		var music2 = get_tree().root.get_node("Main/adventure_music")
		music2.play()
		

	queue_free()
