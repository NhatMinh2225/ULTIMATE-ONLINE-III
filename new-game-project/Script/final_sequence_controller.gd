extends CanvasLayer

# =============== STATE ================
var gun_taken := false
var can_fire := false
var fired := false

# =============== NODES ================
@onready var shadow := $ShadowSprite
@onready var gun_btn: Button = $GunButton
@onready var fire_btn := $FireButton
@onready var gun_sprite := $GunSprite
@onready var blood := $BloodOverlay
@onready var mom := $MomSprite
@onready var reload_sfx: AudioStreamPlayer = $ReloadSfx
@onready var shooting_sound: AudioStreamPlayer = $ShootingSound
@onready var shooting_sound_2: AudioStreamPlayer = $ShootingSound2
@onready var dark_overlay_2: TextureRect = $DarkOverlay2
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var breathing_male: AudioStreamPlayer = $"BreathingMale(heavy)-SoundEffect(hd)-FxSoundWarehouse"
@onready var creepy_footstep: AudioStreamPlayer = $"CreepyFootsteps-SoundEffectForEditing-SoundEffectNexus"
@onready var fall: AudioStreamPlayer = $"Ytmp3Free(mp3Cut_net)"
@onready var btn = $turn_back_final
func _ready():
	btn.final_pressed.connect(_on_final_pressed)

	# ẩn mọi thứ
	dark_overlay_2.visible = false
	gun_btn.visible = false
	fire_btn.visible = false
	gun_sprite.visible = false
	blood.visible = false
	mom.visible = false

	# Bóng người bắt đầu xuất hiện
	_start_shadow_sequence()


# ============================================
# 1) BÓNG NGƯỜI BƯỚC VÀO (TIMER 1)
# ============================================
func _start_shadow_sequence():
	print("[FINAL] Shadow entering…")

	# Animation đơn giản: shadow alpha = 0 → 1 trong 2 giây
	var tween = create_tween()
	shadow.modulate.a = 0
	await get_tree().create_timer(5.0).timeout
	tween.tween_property(shadow, "modulate:a", 1.0, 2.0)
	fade_in_audio(breathing_male, 10.0, -16)
	await get_tree().create_timer(2.0).timeout

	gun_btn.visible = true
	print("[FINAL] Gun button visible.")


# ============================================
# 2) RÚT SÚNG
# ============================================
func _on_gun_button_pressed() -> void:
	gun_taken = true
	print("[FINAL] Gun taken")

	gun_btn.visible = false
	gun_sprite.visible = true

	# hiệu ứng giơ súng lên
	var tween = create_tween()
	gun_sprite.position.y += 80
	tween.tween_property(gun_sprite, "position:y", gun_sprite.position.y - 80, 0.4)

	# rung nhẹ
	reload_sfx.play()
	_start_gun_shake()
	start_final_timer()

func _start_gun_shake():
	var shake = create_tween().set_loops()  # loop vô tận cho đến ending
	shake.tween_property(gun_sprite, "position:x", gun_sprite.position.x + 2, 0.05)
	shake.tween_property(gun_sprite, "position:x", gun_sprite.position.x - 2, 0.05)


# ============================================
# 3) SAU TIMER 2 → CHO PHÉP BẮN HOẶC GOOD ENDING
# ============================================
func start_final_timer():
	# gọi từ ChatUI, timer 2 bắt đầu
	print("[FINAL] Timer 2 started")
	
	# 3 giây cho ví dụ
	await get_tree().create_timer(15.0).timeout
	
	if gun_taken:
		# user đã rút súng → cho nút BẮN
		fire_btn.visible = true
		dark_overlay_2.visible = true
		audio_stream_player.play()
		print("[FINAL] Fire button visible")
	else:
		# user không rút súng → mẹ bước vào
		_show_good_ending()


# ============================================
# 4) BẮN → BAD ENDING
# ============================================
func _on_fire_button_pressed() -> void:
	if fired:
		return
	fired = true
	shooting_sound.play()
	shooting_sound_2.play()

	print("[FINAL] Fired shot!")

	fire_btn.visible = false


	# 1) Animate gun recoil
	_gun_recoil()

	# 2) Screen shake
	_screen_shake()

	# 3) Flash trắng
	_screen_flash()
	
	blood_hit_effect()
	await get_tree().create_timer(2.0).timeout
	fall.play()
	await get_tree().create_timer(13.0).timeout
	
	_show_bad_ending()
	
	


	# kết thúc bad ending
#============================================
#5) GOOD ENDING
#============================================

func _show_good_ending():
	print("[FINAL] Showing mom…")
	mom.modulate.a = 0
	mom.visible = true

	var tween = create_tween()
	tween.tween_property(mom, "modulate:a", 1.0, 1.0)
	
func _gun_recoil():
	var tween = create_tween()

	var original_pos = gun_sprite.position
	var recoil_pos = original_pos + Vector2(0, 40)

	tween.tween_property(gun_sprite, "position", recoil_pos, 0.05)
	tween.tween_property(gun_sprite, "position", original_pos, 0.1)
	
func _screen_shake():
	var shake_amount := 10
	var shake_duration := 0.4
	var steps := 12
	
	var vp := get_viewport()

	var t = create_tween().set_loops(steps)

	for i in steps:
		var offset = Vector2(
 			randf_range(-shake_amount, shake_amount),
  			randf_range(-shake_amount, shake_amount)
		)
		t.tween_property(vp, "canvas_transform:origin", offset, shake_duration / steps)

	# reset sau khi xong
	await t.finished
	vp.canvas_transform = Transform2D()


@onready var flash: ColorRect = $ScreenFlash


func _screen_flash():
	flash.visible = true
	flash.color.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.8, 0.1)   # sáng mạnh
	tween.tween_property(flash, "color:a", 0.0, 3)   # tắt dần


func _show_bad_ending():
	print ("bad ending")
	blood.modulate.a = 0
	$Black.show()
	$GunSprite.hide()
	breathing_male.stop()
	await get_tree().create_timer(4.0).timeout
	$Mom.show()
	await $Mom.type_text("-mm...MOM?")
	await get_tree().create_timer(2.0).timeout
	$Black.hide()
	$Mom.hide()
	btn.show()




func blood_hit_effect():
	blood.modulate.a = 0.0
	blood.visible = true

	var tween := create_tween()

	# Fade-in nhanh (máu xuất hiện đột ngột)
	tween.tween_property(blood, "modulate:a", 1.0, 0.08)

	# Fade-out chậm (máu mờ dần)
	tween.tween_property(blood, "modulate:a", 0.0, 10)
	
func fade_in_audio(audio: AudioStreamPlayer, duration := 15.0, finalAudio := -16):
	audio.volume_db = -40   # bắt đầu gần như im lặng
	audio.play()

	var tween = create_tween()
	tween.tween_property(audio, "volume_db", finalAudio, duration)
	
func _on_final_pressed():
	print("[FINAL] Player pressed final turn back")
	print("[FINAL] MAIN FOUND? → ", get_tree().root.has_node("Main"))
	print("[FINAL] MAIN INSTANCE → ", get_tree().root.get_node_or_null("Main"))

	# Gửi signal lên Main
	var main = get_tree().root.get_node("Main")
	main.on_final_button_pressed()
