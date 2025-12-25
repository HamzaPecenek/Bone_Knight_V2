extends CharacterBody2D
class_name Reaper

const GRAVITY: float = 900.0

@export var grave: Node            # ✅ Inspector’dan GraveSpecial node’unu buraya sürükle-bırak
@export var speed: float = 80.0
@export var max_health: int = 100

@export var attack_interval: float = 1.0
@export var attack_duration: float = 0.4

var health: int
var direction: int = 1

var is_attacking: bool = false
var player_in_attack_area: bool = false
var player_target: Node = null

var attack_cooldown: float = 0.0
var attack_time_left: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBarEnemy

@onready var left_point_x: float  = $LeftPoint.global_position.x
@onready var right_point_x: float = $RightPoint.global_position.x

@onready var attack_area_1: Area2D = $AttackArea1
@onready var attack_area_2: Area2D = $AttackArea2


func _ready() -> void:
	add_to_group("Enemy")

	health = max_health
	if health_bar and health_bar.has_method("apply_max_health"):
		health_bar.apply_max_health(max_health)
	else:
		health_bar.max_value = max_health
	health_bar.set_health(health)

	_update_flip()
	anim.play("walk")


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	# Sayaçları güncelle
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
		if attack_cooldown < 0.0:
			attack_cooldown = 0.0

	if attack_time_left > 0.0:
		attack_time_left -= delta
		if attack_time_left <= 0.0:
			attack_time_left = 0.0
			is_attacking = false
			if health > 0:
				anim.play("walk")

	if health <= 0:
		velocity.x = 0.0
		move_and_slide()
		return

	if is_attacking:
		velocity.x = 0.0
	else:
		if player_in_attack_area and player_target != null and attack_cooldown == 0.0:
			_do_attack()
			velocity.x = 0.0
		else:
			velocity.x = direction * speed

			if direction == -1 and position.x <= left_point_x:
				direction = 1
				_update_flip()
			elif direction == 1 and position.x >= right_point_x:
				direction = -1
				_update_flip()

	move_and_slide()

	if is_on_wall():
		direction = -1 if direction == 1 else 1
		_update_flip()


func _update_flip() -> void:
	anim.flip_h = (direction == -1)


# ------------------------
# MEZARI KAPAT (GARANTİ)
# ------------------------
func _close_grave() -> void:
	if grave and grave.is_inside_tree() and grave.has_method("close_grave"):
		grave.close_grave()


# ------------------------
# DAMAGE / ÖLME
# ------------------------
func take_damage(amount: int, _from_dir: float = 0.0) -> void:
	if health <= 0:
		return

	health -= amount
	if health < 0:
		health = 0

	health_bar.set_health(health)

	if health <= 0:
		_die()
	else:
		anim.play("take_hit")


func _die() -> void:
	is_attacking = false
	player_in_attack_area = false
	player_target = null
	velocity = Vector2.ZERO

	_close_grave()          # ✅ Ölür ölmez mezarı kapat (animation_finished beklemez)
	anim.play("death")


# ------------------------
# SALDIRI + DAMAGE
# ------------------------
func _do_attack() -> void:
	if player_target == null:
		return

	is_attacking = true
	attack_time_left = attack_duration
	attack_cooldown = attack_interval

	var dir: float = sign(player_target.global_position.x - global_position.x)
	if dir != 0.0:
		direction = int(dir)
		_update_flip()

	anim.play("attack")

	if player_target != null and player_target.is_inside_tree() and player_target.has_method("take_damage"):
		player_target.take_damage(5, dir)


# ------------------------
# ATTACK AREA 1 (SOL)
# ------------------------
func _on_attack_area_1_body_entered(body: Node) -> void:
	if health <= 0:
		return
	if not body.is_in_group("Player"):
		return

	player_in_attack_area = true
	player_target = body
	direction = -1
	_update_flip()


func _on_attack_area_1_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	player_in_attack_area = false
	if not is_attacking:
		player_target = null


# ------------------------
# ATTACK AREA 2 (SAĞ)
# ------------------------
func _on_attack_area_2_body_entered(body: Node) -> void:
	if health <= 0:
		return
	if not body.is_in_group("Player"):
		return

	player_in_attack_area = true
	player_target = body
	direction = 1
	_update_flip()


func _on_attack_area_2_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	player_in_attack_area = false
	if not is_attacking:
		player_target = null


# ------------------------
# ANİMASYON BİTİNCE
# ------------------------
func _on_animated_sprite_2d_animation_finished() -> void:
	match anim.animation:
		"take_hit":
			if health > 0:
				anim.play("walk")

		"death":
			_close_grave()   # (zaten _die içinde kapatıyoruz, burada dursa da sorun değil)
			queue_free()
