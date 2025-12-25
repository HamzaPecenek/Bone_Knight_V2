extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the falling object is the player
	if body is Player:
		# Deal massive damage to ensure instant death
		# We pass '0' as direction because falling into the void 
		# shouldn't really have "knockback"
		body.take_damage(9999, 0)
