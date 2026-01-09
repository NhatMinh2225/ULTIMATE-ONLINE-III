extends CharacterBody2D

# -------------------------
#      CONFIG
# -------------------------
@export var speed := 60.0
@export var detect_range := 400.0      # Player bị phát hiện
@export var attack_range := 55.0       # Range tấn công
@export var attack_cooldown := 0.7     # Delay tấn công
@onready var death_sfx: AudioStreamPlayer = $death_sfx
@onready var battle_music: AudioStreamPlayer = $Battle_music
var spoke_low_hp = false
var chase = false
@onready var laugh: AudioStreamPlayer = $laugh
var laughing = false
@onready var health_bar: TextureProgressBar = $HealthBoss/HealthBar
@onready var giant_footstep: AudioStreamPlayer = $giant_footstep
@onready var swing_weapon: AudioStreamPlayer = $"swing weapon"



@export var max_hp := 10            # HP skeleton
var hp := 10
var dead := false

# -------------------------
#      NODE REFERENCES
# -------------------------
@onready var sprite := $AnimatedSprite2D
@onready var hurtbox := $HurtBox
@onready var hitbox := $HitBox
@onready var static_audio: AudioStreamPlayer = $"../StaticAudio"
@onready var voice: AudioStreamPlayer = $Voice
var played_swing = false

var player
var current_dir := "S"
var state := "idle"
var can_attack := true

var dir_list := [
	"N", "NNE", "NEE", "NE",
	"E", "SEE", "SE", "SSE",
	"S", "SSW", "SW", "SWW",
	"W", "NWW", "NW", "NNW"
]

signal death

func _ready():
	hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_bar.visible = true
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# random pitch nhẹ để tránh loop bị lộ
	$"../StaticAudio".pitch_scale = 1.0 + randf_range(-0.015, 0.015)
	if player == null or dead:
		return
	if state == "attack" :
		if sprite.frame == 3:   # frame bạn muốn
			if swing_weapon:
				print("🎯 Swing triggered at frame:", sprite.frame)
				swing_weapon.play()
			
	var distance := global_position.distance_to(player.global_position)

	# Attack nếu đủ gần
	if distance <= attack_range:
		_do_attack()
		return

	# Chase nếu thấy player
	if distance <= detect_range:
		if not laughing:
			laugh.play()
			laughing = true
		if not chase:
			chase = true
			var music = get_tree().root.get_node("Main/adventure_music")
			music.stop()
			battle_music.play()
		_chase_player(delta)

		return

	# Mặc định idle
	_idle()


# ======================================================
#                     COMBAT LOGIC
# ======================================================

func _do_attack():
	if dead:
		return
	
	state = "attack"
	velocity = Vector2.ZERO

	# hướng về player
	var dir_vec = (player.global_position - global_position).normalized()
	_set_direction(dir_vec)

	if can_attack:
		var anim_name = "attack_" + current_dir
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)
		else:
			print("❌ Missing:", anim_name)
			


		can_attack = false
		_reset_attack_after_delay()


func _reset_attack_after_delay():
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# ======================================================
#                     MOVEMENT
# ======================================================

func _chase_player(delta):
	if not giant_footstep.playing :
		giant_footstep.play()
	state = "walk"

	var dir_vec = (player.global_position - global_position).normalized()
	_set_direction(dir_vec)

	velocity = dir_vec * speed
	move_and_slide()

	var anim_name = "walk_" + current_dir
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


func _idle():
	if giant_footstep.playing :
		giant_footstep.stop()
	state = "idle"
	velocity = Vector2.ZERO

	var anim_name = "idle_" + current_dir
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


# ======================================================
#                     DAMAGE + DEATH
# ======================================================

func take_damage(from_pos: Vector2):
	if dead:
		return

	hp -= 1
	health_bar.value = hp
	print("Skeleton HP:", hp)
	
	if hp <= 0:
		_die(from_pos)

func _die(from_pos: Vector2):
	
	var character_ui = get_tree().root.get_node("Main/Character_UI")
	character_ui.get_node("Control2/Control/HPmana").visible = false
	character_ui.get_node("Control2/Control/Skill").visible = false
	character_ui.get_node("Control3/TextureRect/toNpc").visible = true
	if 	character_ui.get_node("Control3/OpenMission").visible == true:
		character_ui.get_node("Control3/OpenMission/TextureRect").visible = true
	character_ui.get_node("Control3/TextureRect/toDemoon/RichTextLabel").text = "Defeat Demonlord (1/1)"
	character_ui.get_node("Control3/TextureRect/toDemoon/TextureRect").visible = false
	static_audio.play()
	battle_music.stop()
	health_bar.visible=false
	var rock = get_tree().root.get_node("Main/Rock")
	rock.get_node("npcBlockingRock").visible = false;
	rock.get_node("npcBlockingRock").disabled = true
	death.emit()
	# move SFX ra khỏi skeleton để không bị xoá
	death_sfx.get_parent().remove_child(death_sfx)
	get_tree().root.add_child(death_sfx)
	death_sfx.play()

	dead = true
	state = "dead"
	velocity = Vector2.ZERO

	# Xác định hướng theo vị trí người tấn công
	var dir_vec = (from_pos - global_position).normalized()
	var angle = rad_to_deg(atan2(dir_vec.x, -dir_vec.y))
	if angle < 0:
		angle += 360
	var index = int(round(angle / 22.5)) % 16
	current_dir = dir_list[index]

	var anim = "death_" + current_dir
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	else:
		sprite.play("death_S")

	# ⚡ BẬT GLITCH NGAY LẬP TỨC
	var glitch = get_tree().root.get_node("Main/GlitchOverlay")
	if glitch:
		glitch.show()

	# Thời gian animation death
	var frames = sprite.sprite_frames.get_frame_count(anim)
	var fps = sprite.sprite_frames.get_animation_speed(anim)
	var dur = frames / fps

	# Chờ animation
	await get_tree().create_timer(dur).timeout

	# Giữ glitch thêm 3 giây
	if glitch:
		await get_tree().create_timer(3.0).timeout
		glitch.hide()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e != self: # nếu không muốn xóa DemonLord chính nó
			e.queue_free()

	# Xoá enemy SAU KHI HIDE GLITCH
	queue_free()

# ======================================================
#                     DIRECTION LOGIC
# ======================================================

func _set_direction(vec: Vector2):
	var angle = rad_to_deg(atan2(vec.x, -vec.y))
	if angle < 0:
		angle += 360

	var index = int(round(angle / 22.5)) % 16
	current_dir = dir_list[index]
