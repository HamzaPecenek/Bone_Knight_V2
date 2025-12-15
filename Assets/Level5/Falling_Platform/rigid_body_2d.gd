extends RigidBody2D

@export var fall_delay: float = 0.25
@export var disappear_delay: float = 0.6   # 👈 YOK OLMA GECİKMESİ
@export var respawn: bool = false
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

	# ⏳ düştükten sonra yok ol
	await get_tree().create_timer(disappear_delay).timeout
	queue_free()
