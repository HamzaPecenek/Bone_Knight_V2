extends CharacterBody2D
class_name DemonBatt

@export var speed: float = 80.0
@export var max_health: int = 100

@export var attack_interval: float = 1.2   # iki saldırı arası bekleme
@export var attack_duration: float = 0.4   # attack state süresi (anim süreye yakın)

@export var bob_amplitude: float = 10.0
@export var bob_speed: float = 3.0

var health: int
var direction: int = 1

var is_attacking: bool = false
var is_dead: bool = false

var player_in_attack_area: bool = false
var player_target: Node = null

var attack_cooldown: float = 0.0
var attack_time_left: float = 0.0

var base_y: float
var bob_t: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: HealthBarEnemy = $HealthBarEnemy

@onready var left_point_x: float = $LeftPoint.global_position.x
@onready var right_point_x: float = $RightPoint.global_position.x


func _ready() -> void:
	add_to_group("Enemy")

	health = max_health
	health_bar.max_health = max_health
	health_bar.set_health(health)

	base_y = global_position.y
	_update_flip()
	anim.play("flight")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# cooldown sayaçları
	if attack_cooldown > 0.0:
		attack_cooldown = max(attack_cooldown - delta, 0.0)

	if attack_time_left > 0.0:
		attack_time_left -= delta
		if attack_time_left <= 0.0:
			attack_time_left = 0.0
			is_attacking = false
			if health > 0:
				anim.play("flight")

	# bob
	bob_t += delta * bob_speed
	global_position.y = base_y + sin(bob_t) * bob_amplitude

	# saldırı sırasında hareket yok
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# player menzildeyse ve cooldown bittiyse 1 kere saldır
	if player_in_attack_area and player_target != null and attack_cooldown == 0.0:
		_do_attack()
		move_and_slide()
		return

	# normal devriye
	velocity.x = float(direction) * speed
	velocity.y = 0.0
	move_and_slide()

	if direction == -1 and global_position.x <= left_point_x:
		direction = 1
		_update_flip()
	elif direction == 1 and global_position.x >= right_point_x:
		direction = -1
		_update_flip()

	if anim.animation != "flight":
		anim.play("flight")


func _update_flip() -> void:
	anim.flip_h = (direction == -1)
	attack_area.scale.x = -1 if anim.flip_h else 1


# --------------------
# ATTACK
# --------------------
func _do_attack() -> void:
	# güvenlik: menzilde değilse saldırma
	if not player_in_attack_area or player_target == null:
		return

	# güvenlik: cooldown varsa saldırma
	if attack_cooldown > 0.0:
		return

	is_attacking = true
	attack_time_left = attack_duration
	attack_cooldown = attack_interval

	var dir: float = sign(player_target.global_position.x - global_position.x)
	if dir != 0.0:
		direction = int(dir)
		_update_flip()

	anim.play("attack")

	# DAMAGE (garanti player bulur)
	var p: Node = player_target
	if not p is Player and p.get_parent() is Player:
		p = p.get_parent()

	if p is Player:
		p.take_damage(5, dir)


# --------------------
# DAMAGE / DEATH
# --------------------
func take_damage(amount: int, _from_dir: float = 0.0) -> void:
	if is_dead:
		return

	health -= amount
	health = max(health, 0)
	health_bar.set_health(health)

	if health <= 0:
		_die()


func _die() -> void:
	is_dead = true
	is_attacking = false
	player_in_attack_area = false
	player_target = null
	velocity = Vector2.ZERO

	anim.play("death")
	await anim.animation_finished
	queue_free()


# --------------------
# ATTACK AREA SIGNALS
# --------------------
func _on_attack_area_body_entered(body: Node) -> void:
	if is_dead:
		return

	# sadece Player'ı hedef al
	var p: Node = body
	if not p is Player and p.get_parent() is Player:
		p = p.get_parent()

	if not p is Player:
		return

	player_in_attack_area = true
	player_target = p

	# yüzünü player'a çevir
	var dir: float = sign(p.global_position.x - global_position.x)
	if dir != 0.0:
		direction = int(dir)
		_update_flip()


func _on_attack_area_body_exited(body: Node) -> void:
	var p: Node = body
	if not p is Player and p.get_parent() is Player:
		p = p.get_parent()

	if p == player_target:
		player_in_attack_area = false
		player_target = null

		# menzilden çıktıysa saldırıyı da kes (attack anim spam'ini önler)
		is_attacking = false
		attack_time_left = 0.0
