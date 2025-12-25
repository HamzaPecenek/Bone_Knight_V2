extends Area2D

@export var heal_amount: int = 20
@export var popup_duration: float = 1.5

var _taken: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _taken:
		return
	if body == null:
		return
	if not body.is_in_group("Player"):
		return

	_taken = true

	# Can bas
	if body.has_method("heal"):
		body.heal(heal_amount)
	else:
		push_warning("HealthCollectable: Player'da heal() yok!")
		queue_free()
		return

	# ✅ HEART POPUP (iyileştim)
	var popup := get_tree().get_first_node_in_group("HeartPopupUI") as HeartPopupUI
	if popup:
		await popup.show_message("Healed.", popup_duration)
	else:
		push_warning("HealthCollectable: HeartPopupUI bulunamadı! (Group ekli mi?)")

	queue_free()
