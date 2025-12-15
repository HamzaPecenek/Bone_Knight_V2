extends Area2D
class_name SpikeTrap

@export var damage: int = 100
@export var auto_cycle := true
@export var open_time := 1.2
@export var closed_time := 1.5

var is_open := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Başlangıç: kapalı
	is_open = false
	hitbox.disabled = true
	anim.play("closed")

	# Debug: signal bağlı mı görmek için
	print("SpikeTrap ready. auto_cycle=", auto_cycle)

	if auto_cycle:
		_cycle()


func open_trap() -> void:
	if is_open:
		return
	is_open = true

	# ✅ Loop olsa bile sorun yok
	hitbox.disabled = false
	anim.play("open")


func close_trap() -> void:
	if not is_open:
		return
	is_open = false

	hitbox.disabled = true
	anim.play("closed")


func _cycle() -> void:
	while true:
		await get_tree().create_timer(closed_time).timeout
		open_trap()
		await get_tree().create_timer(open_time).timeout
		close_trap()


func _on_body_entered(body: Node) -> void:
	print("Trap touched by:", body.name, "is_open=", is_open)

	if not is_open:
		return

	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)
