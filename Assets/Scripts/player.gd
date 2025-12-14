extends CharacterBody2D
class_name Player

# --- MOVEMENT SETTINGS ---
@export var move_speed: float = 250.0
@export var jump_force: float = -300.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var max_jumps: int = 2
var jumps_left: int = 0

# --- HEALTH / COMBAT SETTINGS ---
@export var max_health: int = 100
var health: int
var is_attacking: bool = false
var is_dead: bool = false

# --- NEW ATTACK VARIABLES ---
@export var light_damage: int = 20
@export var heavy_damage: int = 40
@export var light_speed_scale: float = 1.5  # 50% faster
@export var heavy_speed_scale: float = 0.7  # 30% slower
var current_attack_damage: int = 20
var base_attack_duration: float = 0.3 # Matches your scene's Timer wait_time

# --- BOREDOM SETTINGS ---
@export var boredom_threshold: float = 15.0 # Time in seconds
var idle_timer: float = 0.0

# --- RESPAWN SETTINGS ---
@onready var respawn_position: Vector2 = global_position

# --- NODE REFERENCES ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D

@onready var attack_area: Area2D = $AttackAreaP
@onready var attack_shape: CollisionShape2D = $AttackAreaP/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

@onready var health_bar: HealthBarPlayer = $HealthBarPlayer

# Make sure you have created the CanvasLayer and BoredomLabel in your Player scene!
@onready var boredom_label: Label = $CanvasLayer/BoredomLabel 


func _ready() -> void:
	add_to_group("Player")

	health = max_health
	health_bar.max_health = max_health
	health_bar.set_health(health)
	
	# Save the starting position as the first respawn point
	respawn_position = global_position

	_set_attack_enabled(false)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- BOREDOM LOGIC ---
	_handle_boredom(delta)

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
	if not is_attacking and not is_dead:
		if Input.is_action_just_pressed("attack"): # Left Click
			_start_attack(true)
		elif Input.is_action_just_pressed("attack_heavy"): # Right Click
			_start_attack(false)

	move_and_slide()
	_update_animation()

# --- BOREDOM FUNCTION ---
func _handle_boredom(delta: float) -> void:
	var is_active = false
	
	if Input.get_axis("walk_left", "walk_right") != 0:
		is_active = true
	if Input.is_action_pressed("jump"):
		is_active = true
	if Input.is_action_pressed("attack") or Input.is_action_pressed("attack_heavy"):
		is_active = true
		
	if is_active:
		idle_timer = 0.0
	else:
		idle_timer += delta
		
	if idle_timer >= boredom_threshold:
		die_of_boredom()

func die_of_boredom() -> void:
	if is_dead:
		return
	
	if boredom_label:
		boredom_label.visible = true
	
	print("Player died of boredom!")
	# Pass 'true' because this IS a boredom death (Game Over)
	_die(true)


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
func _start_attack(is_light: bool) -> void:
	idle_timer = 0.0 
	is_attacking = true
	
	if is_light:
		current_attack_damage = light_damage
		anim.speed_scale = light_speed_scale
		attack_timer.wait_time = base_attack_duration / light_speed_scale
	else:
		current_attack_damage = heavy_damage
		anim.speed_scale = heavy_speed_scale
		attack_timer.wait_time = base_attack_duration / heavy_speed_scale

	_set_attack_enabled(true)
	attack_timer.start()
	anim.play("attack")


func _set_attack_enabled(enabled: bool) -> void:
	# Use set_deferred to safely change physics properties during a collision
	attack_area.set_deferred("monitoring", enabled)
	attack_shape.set_deferred("disabled", not enabled)


func _on_attack_timer_timeout() -> void:
	is_attacking = false
	_set_attack_enabled(false)
	anim.speed_scale = 1.0 # Reset speed so walking/idle is normal


func _on_attack_area_p_body_entered(body: Node) -> void:
	if body == self:
		return

	if not body.is_in_group("Enemy"):
		return

	if body.has_method("take_damage"):
		var dir: float = sign(body.global_position.x - global_position.x)
		body.take_damage(current_attack_damage, dir)


# -----------------
# PLAYER TAKING DAMAGE
# -----------------
func take_damage(amount: int, from_dir: float = 0.0) -> void:
	if is_dead:
		return
	
	idle_timer = 0.0

	health -= amount
	if health < 0:
		health = 0

	health_bar.set_health(health)

	if from_dir != 0.0:
		velocity.x = 250.0 * from_dir

	if health <= 0:
		# Pass 'false' because this is NOT boredom (Respawn allowed)
		_die(false)
	else:
		anim.play("fall") 


# --- DEATH & RESPAWN SYSTEM ---
func _die(is_boredom_death: bool) -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_set_attack_enabled(false)
	anim.speed_scale = 1.0 # Ensure death animation isn't slow-motion
	
	# Use set_deferred to safely disable physics during a collision
	body_shape.set_deferred("disabled", true)

	health_bar.set_health(0)
	anim.play("death")
	
	# IF DIED OF BOREDOM: Game Over (Stop here)
	if is_boredom_death:
		return

	# IF DIED OF DAMAGE: Wait for animation, then respawn
	await anim.animation_finished
	_respawn()

func _respawn() -> void:
	# 1. Teleport first
	global_position = respawn_position
	
	# 2. Reset Health and State
	health = max_health
	health_bar.set_health(health)
	
	# --- WAIT FOR PHYSICS TO CATCH UP ---
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 3. NOW we become alive and enable collisions
	is_dead = false
	body_shape.set_deferred("disabled", false)
	
	# 4. Reset Animation
	anim.play("idle")


# New function called by the Checkpoint flag
func update_respawn_point(new_position: Vector2) -> void:
	respawn_position = new_position
	print("Checkpoint updated!")

func _on_attack_area_p_body_exited(_body: Node2D) -> void:
	pass

# Clean signals
func _on_interact_area_area_entered(_area):
	pass 

func _on_interact_area_area_exited(_area):
	pass 

func _on_interact_area_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	pass 

func _on_interact_area_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	pass
