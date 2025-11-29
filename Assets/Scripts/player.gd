extends CharacterBody2D
class_name Player

# --- MOVEMENT SETTINGS ---
@export var move_speed: float = 250.0
@export var jump_force: float = -250.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var max_jumps: int = 2
var jumps_left: int = 0

# --- HEALTH / COMBAT SETTINGS ---
@export var max_health: int = 100
var health: int
var is_attacking: bool = false
var is_dead: bool = false

# --- NODE REFERENCES ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D

@onready var attack_area: Area2D = $AttackAreaP
@onready var attack_shape: CollisionShape2D = $AttackAreaP/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

@onready var health_bar: HealthBarPlayer = $HealthBarPlayer


func _ready() -> void:
	add_to_group("Player")

	health = max_health
	health_bar.max_health = max_health
	health_bar.set_health(health)

	_set_attack_enabled(false)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- GRAVITY ---
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0
		
	if is_on_floor():
		jumps_left = max_jumps


	# --- HORIZONTAL MOVEMENT ---
	var dir: float = Input.get_axis("walk_left", "walk_right")
	velocity.x = dir * move_speed

	# Facing direction & attack flip
	if dir != 0.0:
		anim.flip_h = dir < 0.0
		attack_area.scale.x = -1 if anim.flip_h else 1

	if Input.is_action_just_pressed("jump") and jumps_left > 0 and not is_attacking:
		velocity.y = jump_force
		jumps_left -= 1


	# --- ATTACK ---
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dead:
		_start_attack()

	move_and_slide()
	_update_animation()


func _update_animation() -> void:
	if is_dead:
		anim.play("death")
		return

	if is_attacking:
		anim.play("attack")
		return

	if not is_on_floor():
		if velocity.y < 0.0:
			anim.play("jump")
		else:
			anim.play("fall")
	elif velocity.x == 0.0:
		anim.play("idle")
	else:
		anim.play("walk")


# -----------------
# ATTACK SYSTEM
# -----------------
func _start_attack() -> void:
	is_attacking = true
	_set_attack_enabled(true)
	attack_timer.start()


func _set_attack_enabled(enabled: bool) -> void:
	attack_area.monitoring = enabled
	attack_shape.disabled = not enabled


func _on_attack_timer_timeout() -> void:
	is_attacking = false
	_set_attack_enabled(false)


func _on_attack_area_p_body_entered(body: Node) -> void:
	if body == self:
		return

	if not body.is_in_group("Enemy"):
		return

	if body.has_method("take_damage"):
		var dir: float = sign(body.global_position.x - global_position.x)
		body.take_damage(20, dir)


# -----------------
# PLAYER TAKING DAMAGE
# -----------------
func take_damage(amount: int, from_dir: float = 0.0) -> void:
	if is_dead:
		return

	health -= amount
	if health < 0:
		health = 0

	health_bar.set_health(health)

	# Knockback
	if from_dir != 0.0:
		velocity.x = 250.0 * from_dir

	if health <= 0:
		_die()
	else:
		anim.play("fall")  # small hit reaction


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_set_attack_enabled(false)
	body_shape.disabled = true

	health_bar.set_health(0)
	anim.play("death")


func _on_attack_area_p_body_exited(body: Node2D) -> void:
	pass
