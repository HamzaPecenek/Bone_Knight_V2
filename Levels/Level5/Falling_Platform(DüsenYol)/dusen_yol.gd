extends RigidBody2D

@export var fall_delay: float = 0.01
@export var disappear_delay: float = 0.6
@export var respawn: bool = true
@export var respawn_delay: float = 2.0

@onready var trigger: Area2D = $Trigger
@onready var solid: CollisionShape2D = $CollisionShape2D

var _start_pos: Vector2
var _triggered := false

func _ready() -> void:
	_start_pos = global_position
	freeze = true
	trigger.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group("Player"):
		return

	_triggered = true

	# ⏳ düşmeden önce bekle
	await get_tree().create_timer(fall_delay).timeout
	freeze = false  # düşmeye başla

	# ⏳ düştükten sonra kaybol
	await get_tree().create_timer(disappear_delay).timeout

	if respawn:
		_hide_platform()
		await get_tree().create_timer(respawn_delay).timeout
		_respawn_platform()
	else:
		queue_free()

func _hide_platform() -> void:
	# görünmez + çarpışma yok
	visible = false
	solid.disabled = true
	trigger.monitoring = false

func _respawn_platform() -> void:
	# fizik reset
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	rotation = 0.0
	global_position = _start_pos

	# tekrar aktif
	visible = true
	solid.disabled = false
	trigger.monitoring = true
	_triggered = false
