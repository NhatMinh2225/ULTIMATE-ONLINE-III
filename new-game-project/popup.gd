extends Control

@onready var box := $"."       
@onready var label := $Label

var current_tween: Tween = null
var current_timer: SceneTreeTimer = null

func _ready():
	box.modulate.a = 0.0


func show_toast(text: String, duration := 2.0):
	# 🔥 Huỷ tween cũ nếu đang chạy
	if current_tween:
		current_tween.kill()
	
	# 🔥 Huỷ timer cũ nếu đang chạy
	if current_timer:
		current_timer.disconnect("timeout", Callable(self, "_on_timer_timeout"))

	# Reset alpha/nguyên trạng
	box.modulate.a = 0.0
	label.text = text

	# Vị trí float ban đầu
	var start_pos = box.position
	box.position = start_pos + Vector2(0, 10)

	# ---- Fade in + Float up ----
	current_tween = create_tween()
	current_tween.tween_property(box, "modulate:a", 1.0, 0.25)
	current_tween.parallel().tween_property(box, "position", start_pos, 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await current_tween.finished

	# ---- Timer đứng yên duration ----
	current_timer = get_tree().create_timer(duration)
	await current_timer.timeout

	# ---- Fade out + float tiếp ----
	current_tween = create_tween()
	current_tween.tween_property(box, "modulate:a", 0.0, 0.3)
	current_tween.parallel().tween_property(box, "position", start_pos + Vector2(0, -10), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await current_tween.finished

	# Reset vị trí
	box.position = start_pos
