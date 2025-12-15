extends StaticBody2D

@export var item: InvItem
var player: Node2D = null

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

		if player.has_method("collect"):
			player.collect(item)
			await get_tree().create_timer(0.1).timeout
			queue_free()
		else:
			push_warning("Player has no collect() method!")
