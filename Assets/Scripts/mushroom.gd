extends CharacterBody2D

# Mantar çok hareket etmiyor ama yerçekiminden etkilensin istiyorsak:
const GRAVITY: float = 900.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_area: Area2D = $DeathArea1
@onready var main_collision: CollisionShape2D = $CollisionShape2D

var is_dead: bool = false


func _ready() -> void:
	# Başta idle animasyonu oynasın
	anim.play("idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		# Öldükten sonra tamamen sabit kalsın
		velocity = Vector2.ZERO
	else:
		# İstersen yerçekimini iptal edebilirsin, şu an aşağı çeker
		velocity.y += GRAVITY * delta

	move_and_slide()


# ------------------------------------------------
#  Mantarın gerçekten ölmesi için tek fonksiyon
# ------------------------------------------------
func kill() -> void:
	if is_dead:
		return

	is_dead = true
	# "Defer" these changes until the end of the physics frame
	death_area.set_deferred("monitoring", false)
	main_collision.set_deferred("disabled", true)
	
	anim.play("death")


# ------------------------------------------------
#  Player mantarın tepesine bastığında
# ------------------------------------------------
func _on_death_area_1_body_entered(body: Node) -> void:
	# Player grubundaysa ve mantar henüz ölmediyse
	if not is_dead and body.is_in_group("Player"):
		kill()


# ------------------------------------------------
#  Ölüm animasyonu bitince mantarı sahneden sil
#  (AnimatedSprite2D'nin animation_finished sinyali buna bağlı olmalı)
# ------------------------------------------------
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "death":
		queue_free()
