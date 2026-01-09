extends CharacterBody2D

@export var speed := 150.0
@export var attack_range := 40.0

@export var clan := "[Clan]𝕷𝖊𝖌𝖊𝖓𝖉"
@export var player_name := "Challengerz[lv.829]"

@onready var sprite := $AnimatedSprite2D
@onready var name_label := $NameLv
@onready var clan_name := $ClanName
@onready var walking: AudioStreamPlayer = $Walking
@onready var attacking_sfx: AudioStreamPlayer = $Attacking_sfx


var current_dir := "S"
var attack_target = null
var attacking := false
var moving := false
var mouse_held := false

var dir_list := [
	"N", "NNE", "NEE", "NE",
	"E", "SEE", "SE", "SSE",
	"S", "SSW", "SW", "SWW",
	"W", "NWW", "NW", "NNW"
]

var target_pos: Vector2


# ============================================================
# 						READY
# ============================================================
func _ready():
	name_label.text = player_name
	clan_name.text = clan
	name_label.add_theme_font_size_override("font_size", 12)
	clan_name.add_theme_font_size_override("font_size", 12)


# ============================================================
# 						INPUT
# ============================================================
func _input(event):
	if Global.is_input_locked():
		return

	# --- CLICK ENEMY ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var space_state = get_world_2d().direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		params.position = get_global_mouse_position()
		params.collide_with_areas = true
		params.collide_with_bodies = true

		var result = space_state.intersect_point(params)
		var clicked_enemy = null

		for r in result:
			if r.collider.is_in_group("enemy"):
				clicked_enemy = r.collider
				break

		if clicked_enemy != null and not clicked_enemy.dead:

			attack_target = clicked_enemy
			var dist := global_position.distance_to(clicked_enemy.global_position)

			if dist > attack_range:
				target_pos = clicked_enemy.global_position
				moving = true
			else:
				_start_attack(clicked_enemy)

			return  # dừng xử lý click đất

	# --- CLICK ĐẤT ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_viewport().gui_get_hovered_control() != null:
				return

			mouse_held = true
			attack_target = null
			target_pos = get_global_mouse_position()
			moving = true
		else:
			mouse_held = false


# ============================================================
# 						PHYSICS
# ============================================================
func _physics_process(delta):
	if attacking:
		velocity = Vector2.ZERO
		return

	if Global.movement_locked:
		velocity = Vector2.ZERO
		_play_idle()
		return

	if mouse_held and not Global.is_input_locked():
		target_pos = get_global_mouse_position()
		moving = true

	# --- AUTO ATTACK ---
	if attack_target != null and not attacking:
		var dist := global_position.distance_to(attack_target.global_position)

		if dist <= attack_range:
			moving = false
			_start_attack(attack_target)
			return

	# --- MOVEMENT ---
	if moving:
		var to_target := target_pos - global_position
		var dist := to_target.length()

		if dist > 3:
			var dir_vec := to_target.normalized()
			velocity = dir_vec * speed
			move_and_slide()
			_play_walk_animation(dir_vec)
		else:
			moving = false
			velocity = Vector2.ZERO
			_play_idle()
	else:
		velocity = Vector2.ZERO


# ============================================================
# 						ANIMATIONS
# ============================================================
func _play_idle():
	if walking.playing:
		walking.stop()

	var anim := "idle_" + current_dir
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


func _play_walk_animation(vec: Vector2):
	if not walking.playing:
		walking.play()

	var angle := rad_to_deg(atan2(vec.x, -vec.y))
	if angle < 0:
		angle += 360

	var index := int(round(angle / 22.5)) % 16
	current_dir = dir_list[index]

	var anim := "walk_" + current_dir
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


# ============================================================
# 						 ATTACK
# ============================================================
func _start_attack(enemy):
	# NGĂN spam attack
	if attacking:
		return
	


	attacking = true
	attack_target = null  # ← ngắt auto-attack lập tức
	moving = false
	mouse_held = false
	velocity = Vector2.ZERO

	# hướng về enemy
	var dir_vec = (enemy.global_position - global_position).normalized()
	_update_attack_direction(dir_vec)
	if attacking_sfx:
		attacking_sfx.play()

	# animation
	var anim := "attack_" + current_dir
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

	# gây damage
	if enemy.has_method("take_damage"):
		enemy.take_damage(global_position)

	# chờ animation attack
	var frames = sprite.sprite_frames.get_frame_count(anim)
	var fps = sprite.sprite_frames.get_animation_speed(anim)
	var duration = frames / fps

	await get_tree().create_timer(duration).timeout

	# cooldown ngắn
	await get_tree().create_timer(0.15).timeout

	attacking = false
	_play_idle()


func _update_attack_direction(vec: Vector2):
	var angle := rad_to_deg(atan2(vec.x, -vec.y))
	if angle < 0:
		angle += 360
	current_dir = dir_list[int(round(angle / 22.5)) % 16]
