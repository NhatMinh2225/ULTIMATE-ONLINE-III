extends Control

signal chat_started

@onready var button = $Panel/ButtonChat
@onready var panel = $Panel

func _ready():
	button.pressed.connect(_on_chat_pressed)

func _on_chat_pressed():
	emit_signal("chat_started")
	queue_free()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not panel.get_global_rect().has_point(mouse_pos):
			queue_free()
