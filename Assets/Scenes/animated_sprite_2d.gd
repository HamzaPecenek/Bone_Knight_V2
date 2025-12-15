extends AnimatedSprite2D

@export var rotate_speed := 2.0   # yavaş dönsün

func _process(delta):
	rotation += rotate_speed * delta
