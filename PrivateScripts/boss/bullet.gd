extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var player = get_parent().find_child("Player")

var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	acceleration = (player.position - position).normalized() * 70
	velocity += acceleration * delta
	rotation = velocity.angle()
	
	velocity = velocity.limit_length(150)
	position += velocity * delta
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(20, sign(body.global_position.x - global_position.x))
	queue_free()
