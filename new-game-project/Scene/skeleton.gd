extends CharacterBody2D

# -------------------------
#      CONFIG
# -------------------------
@export var speed := 60.0
@export var detect_range := 400.0      # Player bị phát hiện
@export var attack_range := 35.0       # Range tấn công
@export var attack_cooldown := 0.7     # Delay tấn công

@export var max_hp := 2                # HP skeleton
var hp := 2
var dead := false

# -------------------------
#      NODE REFERENCES
# -------------------------
@onready var sprite := $AnimatedSprite2D
@onready var hurtbox := $HurtBox
@onready var hitbox := $HitBox
@onready var sfx_death_1: AudioStreamPlayer = $sfx_death_1
@onready var sfx_death_2: AudioStreamPlayer = $sfx_death_2
@onready var sfx_death_3: AudioStreamPlayer = $sfx_death_3
var death_id:=1
@onready var health_bar: TextureProgressBar = $HealthBar


var player
var current_dir := "S"
var state := "idle"
var can_attack := true
static var next_death_id := 1


var dir_list := [
	"N", "NNE", "NEE", "NE",
	"E", "SEE", "SE", "SSE",
	"S", "SSW", "SW", "SWW",
	"W", "NWW", "NW", "NNW"
]

func _ready():
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	
		# Setup health bar
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_bar.visible = true
		# gán death_id theo vòng 1→2→3→1→2→3...
	death_id = next_death_id
	next_death_id += 1
	if next_death_id > 3:
		next_death_id = 1

func _physics_process(delta):
	if player == null or dead:
		return

	var distance := global_position.distance_to(player.global_position)

	# Attack nếu đủ gần
	if distance <= attack_range:
		_do_attack()
		return

	# Chase nếu thấy player
	if distance <= detect_range:
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
	state = "walk"

	var dir_vec = (player.global_position - global_position).normalized()
	_set_direction(dir_vec)

	velocity = dir_vec * speed
	move_and_slide()

	var anim_name = "walk_" + current_dir
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


func _idle():
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
	dead = true
	state = "dead"
	health_bar.visible = false
	velocity = Vector2.ZERO
	$HurtBox/CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	hitbox.input_pickable = false
	hurtbox.input_pickable = false

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
		
	match death_id:
		1:
			sfx_death_1.play()
		2:
			sfx_death_2.play()
		3:
			sfx_death_3.play()

	var frames = sprite.sprite_frames.get_frame_count(anim)
	var fps = sprite.sprite_frames.get_animation_speed(anim)
	var dur = frames / fps

	await get_tree().create_timer(dur).timeout
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
