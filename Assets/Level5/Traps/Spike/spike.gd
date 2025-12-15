extends Area2D
class_name Spike

@export var damage: int = 100

@export var auto_cycle: bool = true
@export var open_time: float = 0.8     # açık kalma süresi
@export var closed_time: float = 1.2   # kapalı kalma süresi

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D2
@onready var col: CollisionShape2D = $CollisionShape2D

var is_open: bool = false
var hit_cooldown := {}   # aynı anda sürekli ticklemesin diye

func _ready() -> void:
	# Başlangıç kapalı
	set_open(false)

	# Sinyal bağlı değilse otomatik bağla (istersen elle de bağlayabilirsin)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		body_entered.connect(_on_body_entered)
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		body_exited.connect(_on_body_exited)

	if auto_cycle:
		_cycle()

func set_open(open: bool) -> void:
	is_open = open

	# Açıkken collision aktif, kapalıyken kapalı
	col.disabled = not is_open

	# Animasyon isimlerini kendi SpriteFrames’ine göre ayarla:
	# Örn: "open", "close", "idle", "attack" vs.
	if is_open:
		if anim.sprite_frames and anim.sprite_frames.has_animation("open"):
			anim.play("open")
		elif anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
			anim.play("attack")
		else:
			anim.play()
	else:
		if anim.sprite_frames and anim.sprite_frames.has_animation("closed"):
			anim.play("closed")
		elif anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
		else:
			anim.stop()

func _cycle() -> void:
	while is_inside_tree() and auto_cycle:
		set_open(true)
		await get_tree().create_timer(open_time).timeout
		set_open(false)
		await get_tree().create_timer(closed_time).timeout

func _on_body_entered(body: Node) -> void:
	if not is_open:
		return
	if not body.is_in_group("Player"):
		return
	if hit_cooldown.has(body):
		return

	hit_cooldown[body] = true

	if body.has_method("take_damage"):
		body.take_damage(damage, sign(body.global_position.x - global_position.x))

	# aynı body içerdeyken spam olmasın diye küçük cooldown
	await get_tree().create_timer(0.4).timeout
	hit_cooldown.erase(body)

func _on_body_exited(body: Node) -> void:
	# Çıkınca cooldown temizle
	if hit_cooldown.has(body):
		hit_cooldown.erase(body)
