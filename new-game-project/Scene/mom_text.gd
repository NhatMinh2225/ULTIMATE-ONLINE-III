extends Label

@export var speed := 0.15  # thời gian delay mỗi ký tự

func type_text(full_text: String) -> void:
	text = ""
	
	for i in full_text.length():
		text += full_text[i]
		await get_tree().create_timer(speed).timeout
