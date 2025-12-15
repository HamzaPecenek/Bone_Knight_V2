extends CharacterBody2D
class_name Skeleton

const GRAVITY: float = 900.0

@export var grave_node: NodePath
@export var speed: float = 80.0
@export var max_health: int = 60

# ✅ Player yaklaşınca uyanma mesafesi
@export var wake_range: float = 160.0

# ✅ Uyanınca mezardan çıkma animasyonu
@export var spawn_animation: String = "idle"

# ✅ X sınırı
@export var min_x: float = 1651
@export var max_x: float = 1816
@export var edge_padding: float = 2.0

@export var attack_interval: float = 1.0
@export var attack_duration: float = 0.4
@export var attack_damage: int = 5

var health: int
var direction: int = 1

var is_awake: bool = false
var is_spawning: bool = false

var is_attacking: bool = false
var player_in_attack_area: bool = false
var player_target: Node = null

var attack_cooldown: float = 0.0
var attack_time_left: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBarEnemy
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

	# ✅ Başta uyku modu: saldırı alanlarını kapat
	attack_area_1.monitoring = false
	attack_area_2.monitoring = false

	# ✅ Başta hiçbir anim akmasın (istersen burada ilk frame'i ayarlayabilirsin)
	anim.stop()
	anim.frame = 0


func _physics_process(delta: float) -> void:
	# ✅ Uyanmadıysa sadece player yakın mı kontrol et
	if not is_awake:
		velocity = Vector2.ZERO
		move_and_slide()

		var p: Node = get_tree().get_first_node_in_group("Player")
		if p != null:
			var dist: float = abs(p.global_position.x - global_position.x)
			if dist <= wake_range:
				player_target = p
				_wake_up()
		return

	# ✅ Uyanma animasyonu sırasında hareket/atak yok, gravity yok
	if is_spawning:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ✅ Normal hayata geçince gravity aktif
	velocity.y += GRAVITY * delta

	# Cooldown
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
		if attack_cooldown < 0.0:
			attack_cooldown = 0.0

	# Attack süresi
	if attack_time_left > 0.0:
		attack_time_left -= delta
		if attack_time_left <= 0.0:
			attack_time_left = 0.0
			is_attacking = false
			if health > 0:
				anim.play("walk")

	# öldüyse
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

			# X sınırı
			if direction == -1 and global_position.x <= min_x + edge_padding:
				direction = 1
				_update_flip()
			elif direction == 1 and global_position.x >= max_x - edge_padding:
				direction = -1
				_update_flip()

	move_and_slide()

	global_position.x = clamp(global_position.x, min_x, max_x)

	if is_on_wall():
		direction = -1 if direction == 1 else 1
		_update_flip()


func _wake_up() -> void:
	is_awake = true
	is_spawning = true

	# uyanınca saldırı alanları açılacak ama spawn bitince efektif olsun
	attack_area_1.monitoring = true
	attack_area_2.monitoring = true

	# idle (mezardan çıkış) 1 kere oynasın
	if anim.sprite_frames and anim.sprite_frames.has_animation(spawn_animation):
		anim.sprite_frames.set_animation_loop(spawn_animation, false)
		anim.play(spawn_animation)
	else:
		# idle yoksa direkt yürüsün
		is_spawning = false
		anim.play("walk")


func _update_flip() -> void:
	anim.flip_h = (direction == -1)


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
	anim.play("death")


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
		player_target.take_damage(attack_damage, dir)


func _on_attack_area_1_body_entered(body: Node) -> void:
	if health <= 0:
		return
	if not is_awake or is_spawning:
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


func _on_attack_area_2_body_entered(body: Node) -> void:
	if health <= 0:
		return
	if not is_awake or is_spawning:
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


func _on_animated_sprite_2d_animation_finished() -> void:
	match anim.animation:
		"idle":
			# ✅ mezardan çıkış bitti -> yürüyüşe geç
			is_spawning = false
			if health > 0:
				anim.play("walk")

		"take_hit":
			if health > 0 and not is_spawning:
				anim.play("walk")

		"death":
			if grave_node != NodePath("") and has_node(grave_node):
				var grave = get_node(grave_node)
				if grave and grave.has_method("close_grave"):
					grave.close_grave()
			queue_free()
