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
@export var light_speed_scale: float = 1.5
@export var heavy_speed_scale: float = 0.7
var current_attack_damage: int = 20
var base_attack_duration: float = 0.3

# --- BOREDOM SETTINGS ---
@export var boredom_threshold: float = 15.0
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
@onready var boredom_label: Label = $CanvasLayer/BoredomLabel

@onready var inv_ui := get_parent().get_node("CanvasLayer/Inventory")
@onready var tutorial_ui := get_parent().get_node("TutorialUI")

# ✅ Interact hint UI (F için) - sahnede yoksa null kalır
@onready var interact_hint_ui := get_parent().get_node_or_null("CanvasLayer/InteractHintUI")

# ✅ Şu an içinde olduğumuz InteractTutorialArea (F basınca buraya konuşacak)
var current_interact_area: Node = null

# --- LADDER ---
var on_ladder: bool = false
@export var ladder_speed := 180.0

func _ready() -> void:
	add_to_group("Player")

	health = max_health
	health_bar.max_health = max_health
	health_bar.set_health(health)

	respawn_position = global_position
	_set_attack_enabled(false)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# -------- LADDER --------
	if on_ladder:
		velocity = Vector2.ZERO

		if Input.is_action_pressed("ladder_up"):
			velocity.y = -ladder_speed
		elif Input.is_action_pressed("ladder_down"):
			velocity.y = ladder_speed

		move_and_slide()
		anim.play("idle")
		return
	# ------------------------

	_handle_boredom(delta)

	# GRAVITY
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0:
		velocity.y = 0

	if is_on_floor():
		jumps_left = max_jumps

	# HORIZONTAL MOVE
	var dir := Input.get_axis("walk_left", "walk_right")
	velocity.x = dir * move_speed

	if dir != 0:
		anim.flip_h = dir < 0
		attack_area.scale.x = -1 if anim.flip_h else 1

	# JUMP
	if Input.is_action_just_pressed("jump") and jumps_left > 0 and not is_attacking:
		velocity.y = jump_force
		jumps_left -= 1

	# --- ATTACK ---
	if not is_attacking and not is_dead:
		if Input.is_action_just_pressed("attack"):
			_start_attack(true)
		elif Input.is_action_just_pressed("attack_heavy"):
			_start_attack(false)

	move_and_slide()
	_update_animation()

# ----------------------------------------------------
# INVENTORY + TUTORIAL + INTERACT INPUT
# ----------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	# ✅ F: interact (InputMap: interact = F)
	if event.is_action_pressed("interact"):
		if current_interact_area and current_interact_area.has_method("try_interact"):
			current_interact_area.try_interact()
			get_viewport().set_input_as_handled()
			return

	# I: toggle inventory
	if event.is_action_pressed("inventory_toggle"):
		inv_ui.toggle()

		if tutorial_ui and tutorial_ui.has_method("on_inventory_toggled"):
			tutorial_ui.on_inventory_toggled(inv_ui.visible)

		get_viewport().set_input_as_handled()
		return

	# ESC: close inventory (if open)
	if event.is_action_pressed("ui_cancel"):
		if inv_ui and inv_ui.visible:
			inv_ui.visible = false

			if tutorial_ui and tutorial_ui.has_method("on_inventory_closed_with_esc"):
				tutorial_ui.on_inventory_closed_with_esc()

			get_viewport().set_input_as_handled()
			return

# ----------------------------------------------------
# INTERACT TUTORIAL AREA (F hint + F interact)
# Bu sinyaller InteractTutorialArea'dan Player'a bağlanacak:
# body_entered -> _on_interact_tutorial_area_body_entered
# body_exited  -> _on_interact_tutorial_area_body_exited
# ----------------------------------------------------
func _on_interact_tutorial_area_body_entered(body: Node2D) -> void:
	# Bu fonksiyon Player'a bağlandıysa body = Player gelir.
	# Ama güvenli kontrol yapalım:
	if body == null:
		return
	if body != self:
		return

	# Hangi Area tetikledi? Godot'ta sinyal bağlarken "Bind" ile area referansı veremiyorsan:
	# Alternatif: current_interact_area'yı Player'a değil Area'nın kendisi set eder.
	# Yine de pratik çözüm: sahnede tek interact alanı varsa, grup ile bul:
	# (En stabil yöntem: sinyali Area'nın scriptine bağla, Player'a değil.)
	if current_interact_area == null:
		# Bir tane InteractTutorialArea bulmaya çalış
		var a = get_tree().get_first_node_in_group("InteractTutorialArea")
		if a:
			current_interact_area = a

	if interact_hint_ui and interact_hint_ui.has_method("show_hint"):
		interact_hint_ui.show_hint("Etkileşime girmek için F'e basın")

func _on_interact_tutorial_area_body_exited(body: Node2D) -> void:
	if body == null:
		return
	if body != self:
		return

	if interact_hint_ui and interact_hint_ui.has_method("hide_hint"):
		interact_hint_ui.hide_hint()

	# Çıkınca area bilgisini temizle
	current_interact_area = null

# ----------------------------------------------------
# INVENTORY COLLECT
# ----------------------------------------------------
func collect(item: InvItem) -> bool:
	if item == null:
		return false
	if inv_ui == null or inv_ui.inv == null:
		return false

	var inv = inv_ui.inv

	for s in inv.slots:
		if s.item == item:
			s.amount += 1
			inv_ui.update_slots()
			return true

	for s in inv.slots:
		if s.item == null:
			s.item = item
			s.amount = 1
			inv_ui.update_slots()
			return true

	return false

# ----------------------------------------------------
# BOREDOM
# ----------------------------------------------------
func _handle_boredom(delta: float) -> void:
	var active := false

	if Input.get_axis("walk_left", "walk_right") != 0:
		active = true
	if Input.is_action_pressed("jump"):
		active = true
	if Input.is_action_pressed("attack") or Input.is_action_pressed("attack_heavy"):
		active = true

	if active:
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
	_die(true)

# ----------------------------------------------------
# ANIMATION
# ----------------------------------------------------
func _update_animation() -> void:
	if is_dead:
		anim.play("death")
		return

	if is_attacking:
		anim.play("attack")
		return

	if not is_on_floor():
		anim.play("jump" if velocity.y < 0 else "fall")
	elif velocity.x == 0:
		anim.play("idle")
	else:
		anim.play("walk")

# ----------------------------------------------------
# ATTACK SYSTEM
# ----------------------------------------------------
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
	attack_area.set_deferred("monitoring", enabled)
	attack_shape.set_deferred("disabled", not enabled)

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	_set_attack_enabled(false)
	anim.speed_scale = 1.0

func _on_attack_area_p_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return
	if body == self:
		return
	if not body.is_in_group("Enemy"):
		return

	if body.has_method("take_damage"):
		var dir: float = sign(body.global_position.x - global_position.x)
		body.take_damage(current_attack_damage, dir)

# ----------------------------------------------------
# DAMAGE / DEATH
# ----------------------------------------------------
func take_damage(amount: int, from_dir: float = 0.0) -> void:
	if is_dead:
		return

	idle_timer = 0
	health -= amount
	if health < 0:
		health = 0

	health_bar.set_health(health)

	if from_dir != 0.0:
		velocity.x = 250.0 * from_dir

	if health <= 0:
		_die(false)
	else:
		anim.play("fall")

func _die(is_boredom: bool) -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_set_attack_enabled(false)
	anim.speed_scale = 1.0

	body_shape.set_deferred("disabled", true)
	anim.play("death")

	if is_boredom:
		return

	await anim.animation_finished
	_respawn()

func _respawn() -> void:
	global_position = respawn_position

	health = max_health
	health_bar.set_health(health)

	await get_tree().physics_frame
	await get_tree().physics_frame

	is_dead = false
	body_shape.set_deferred("disabled", false)
	anim.play("idle")

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	health_bar.set_health(health)
	if is_dead:
		return
	if amount <= 0:
		return

func update_respawn_point(new_position: Vector2) -> void:
	respawn_position = new_position
	print("Checkpoint updated!")

# ----------------------------------------------------
# UNUSED SIGNALS (kalsın diye dokunmadım)
# ----------------------------------------------------
func _on_attack_area_p_body_exited(_body: Node2D) -> void:
	pass

func _on_interact_area_area_entered(_area):
	pass

func _on_interact_area_area_exited(_area):
	pass

func _on_interact_area_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	pass

func _on_interact_area_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	pass
