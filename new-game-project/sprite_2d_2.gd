extends Sprite2D

@onready var player := get_tree().root.get_node("Main/Player")

const HIDE_DISTANCE := 300.0

func _process(delta):

	var target_position = Vector2(4496.0,601.0)
	# 1. Vector từ player → boss
	var dir_world = target_position - player.global_position
	var dist = dir_world.length()

	# 2. Ẩn khi đến gần boss
	if dist < HIDE_DISTANCE:
		visible = false
		return
	else:
		visible = true

	# 3. Hướng normalized
	var dir = dir_world.normalized()

	# 4. Lấy kích thước màn hình (UI)
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size * 0.5

	# 5. Đặt mũi tên ở cạnh màn hình (vòng tròn)
	var radius = min(viewport_size.x, viewport_size.y) * 0.4
	var arrow_pos = screen_center + dir * radius

	global_position = arrow_pos

	# 6. Xoay theo hướng boss
	rotation = dir.angle() + deg_to_rad(270)   # Nếu sprite của bạn hướng lên
