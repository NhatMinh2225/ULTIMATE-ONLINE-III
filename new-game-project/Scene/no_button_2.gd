extends TextureButton

var base_pos := Vector2.ZERO
@export var amount := 3.0        # độ rung (px)
@export var speed := 0.03        # thời gian giữa mỗi frame rung

func _ready():
	base_pos = position
	_start_shake_loop()


func _start_shake_loop():
	while true:
		# tạo vị trí ngẫu nhiên quanh base_pos
		position = base_pos + Vector2(
			randf_range(-amount, amount),
			randf_range(-amount, amount)
		)

		await get_tree().create_timer(speed).timeout
