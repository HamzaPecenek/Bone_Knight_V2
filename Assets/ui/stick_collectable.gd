extends StaticBody2D

@export var item: InvItem
@export var popup_text: String = "Bu önemli gözüküyor."
@export var popup_duration: float = 2.0

var player: Node2D = null
var _taken: bool = false

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if _taken:
		return
	if body == null:
		return
	if not body.is_in_group("Player"):
		return

	player = body

	if player.has_method("collect"):
		_taken = true

		# Inventory'e ekle
		player.collect(item)

		# ✅ POPUP GÖSTER
		var popup := get_tree().get_first_node_in_group("CoinPopupUI") as CoinPopupUI
		if popup:
			popup.show_message(popup_text, popup_duration)
		else:
			print("CoinPopupUI bulunamadı! (Group ekli mi?)")

		await get_tree().create_timer(0.1).timeout
		queue_free()
	else:
		push_warning("Player has no collect() method!")

func _on_coin_trigger_body_entered(_body: Node2D) -> void:
	pass
