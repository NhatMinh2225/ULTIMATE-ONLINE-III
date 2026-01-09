extends CanvasLayer

@export var color_rect: ColorRect
@export var normal_material: Material
@export var glitch_material: ShaderMaterial

func _ready():
	# Bắt đầu bằng material bình thường
	if color_rect and normal_material:
		color_rect.material = normal_material

func play_glitch(duration := 0.45):
	if color_rect == null:
		return
	
	color_rect.material = glitch_material
	await get_tree().create_timer(duration).timeout
	color_rect.material = normal_material
