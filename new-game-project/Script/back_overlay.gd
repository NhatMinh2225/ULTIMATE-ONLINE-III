extends CanvasLayer

@onready var tex: TextureRect = $TextureRect
@onready var video := $VideoStreamPlayer

func _ready():
	tex.visible = false
	video.visible = false

func show_overlay():
	print("BACK: Show overlay")
	tex.visible = true
	video.visible = true

func hide_overlay():
	print("BACK: Hide overlay")
	tex.visible = false
	video.visible = false
