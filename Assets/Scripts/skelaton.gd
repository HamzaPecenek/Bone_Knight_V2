extends CharacterBody2D
class_name Skeleton

const GRAVITY: float = 900.0

@export var grave_node: NodePath
@export var speed: float = 80.0
@export var max_health: int = 60

# Player yaklaşınca uyanma mesafesi
@export var wake_range: float = 160.0

# Uyanınca mezardan çıkma animasyonu
@export var spawn_animation: String = "idle"

# X sınırı
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
# ✅ FIXED: New variable to lock logic when hit
var is_hurt: bool = false 

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

	# Başta uyku modu: saldırı alanlarını kapat
	attack_area_1.monitoring = false
	attack_area_2.monitoring = false

	anim.stop()
	anim.frame = 0

func _physics_process(delta: float) -> void:
	# 1. Yerçekimi her zaman var (Spawning hariç)
	if not is_spawning:
		velocity.y += GRAVITY * delta

	# 2. Öncelikli Durumlar: Ölü, Spawning veya Hurt ise hareket etme
	if health <= 0:
		velocity.x = 0
		move_and_slide()
		return

	if is_spawning:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# ✅ FIXED: Hasar alıyorsak kımıldama ve diğer kodları çalıştırma
	if is_hurt:
		velocity.x = 0
		move_and_slide()
		return

	# 3. Uyanma Kontrolü
	if not is_awake:
		velocity.x = 0
		move_and_slide()
		var p: Node = get_tree().get_first_node_in_group("Player")
		if p != null:
			var dist: float = abs(p.global_position.x - global_position.x)
			if dist <= wake_range:
				player_target = p
				_wake_up()
		return

	# 4. Timerlar
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
		if attack_cooldown < 0.0: attack_cooldown = 0.0

	if attack_time_left > 0.0:
		attack_time_left -= delta
		if attack_time_left <= 0.0:
			attack_time_left = 0.0
			is_attacking = false
			# Saldırı bitti, eğer canı varsa yürüme animasyonuna dön
			if health > 0: 
				anim.play("walk")

	# 5. Hareket ve Saldırı Mantığı
	if is_attacking:
		velocity.x = 0
	else:
		# ✅ FIXED: Hedef varsa ve uyanıksa, HER ZAMAN hedefe dön
		if player_target != null:
			var direction_to_player = sign(player_target.global_position.x - global_position.x)
			if direction_to_player != 0:
				direction = int(direction_to_player)
				_update_flip()

		# Saldırı menzili kontrolü
		if player_in_attack_area and player_target != null and attack_cooldown == 0.0:
			_do_attack()
			velocity.x = 0
		else:
			# Yürüme
			velocity.x = direction * speed
			
			# ✅ FIXED: Sadece player yoksa (Patrol modu) duvarlardan sek
			# Player varsa duvara toslasa bile dönmemeli, player'a bakmalı
			if player_target == null:
				if direction == -1 and global_position.x <= min_x + edge_padding:
					direction = 1
					_update_flip()
				elif direction == 1 and global_position.x >= max_x - edge_padding:
					direction = -1
					_update_flip()

	move_and_slide()
	
	# Pozisyonu her zaman clamp'le (dışarı taşmasın)
	global_position.x = clamp(global_position.x, min_x, max_x)

func _wake_up() -> void:
	is_awake = true
	is_spawning = true
	attack_area_1.monitoring = true
	attack_area_2.monitoring = true

	if anim.sprite_frames and anim.sprite_frames.has_animation(spawn_animation):
		anim.sprite_frames.set_animation_loop(spawn_animation, false)
		anim.play(spawn_animation)
	else:
		is_spawning = false
		anim.play("walk")

func _update_flip() -> void:
	anim.flip_h = (direction == -1)

func take_damage(amount: int, _from_dir: float = 0.0) -> void:
	if health <= 0: return

	health -= amount
	if health < 0: health = 0
	health_bar.set_health(health)

	if health <= 0:
		_die()
	else:
		# ✅ FIXED: Hasar alınca 'is_hurt' aç, atağı iptal et
		is_hurt = true
		is_attacking = false 
		anim.play("take_hit")

func _die() -> void:
	is_attacking = false
	is_hurt = false # Ölürken hurt takılı kalmasın
	player_in_attack_area = false
	player_target = null
	velocity = Vector2.ZERO
	anim.play("death")

func _do_attack() -> void:
	if player_target == null: return

	is_attacking = true
	attack_time_left = attack_duration
	attack_cooldown = attack_interval
	
	# Saldırırken hedefe dön (garanti olsun)
	var dir = sign(player_target.global_position.x - global_position.x)
	if dir != 0:
		direction = int(dir)
		_update_flip()

	anim.play("attack")

	if player_target != null and player_target.is_inside_tree() and player_target.has_method("take_damage"):
		player_target.take_damage(attack_damage, direction)

# --- Area Signals ---
# ✅ FIXED: Area logic sadece "menzilde mi" bilgisini tutmalı
# Yönü physics_process içinde hallediyoruz
func _on_attack_area_1_body_entered(body: Node) -> void:
	if health > 0 and is_awake and not is_spawning and body.is_in_group("Player"):
		player_in_attack_area = true
		player_target = body

func _on_attack_area_1_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_attack_area = false

func _on_attack_area_2_body_entered(body: Node) -> void:
	if health > 0 and is_awake and not is_spawning and body.is_in_group("Player"):
		player_in_attack_area = true
		player_target = body

func _on_attack_area_2_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_attack_area = false

# --- Animation Finished ---
func _on_animated_sprite_2d_animation_finished() -> void:
	match anim.animation:
		"idle": # spawn bitişi
			is_spawning = false
			if health > 0: anim.play("walk")

		"take_hit":
			# ✅ FIXED: Hasar animasyonu bitince kontrolü geri ver
			is_hurt = false
			if health > 0:
				anim.play("walk")

		"death":
			if grave_node != NodePath("") and has_node(grave_node):
				var grave = get_node(grave_node)
				if grave and grave.has_method("close_grave"):
					grave.close_grave()
			queue_free()
