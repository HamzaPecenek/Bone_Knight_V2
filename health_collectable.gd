extends Area2D
@export var heal_amount := 20

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.heal(heal_amount)
		queue_free()
