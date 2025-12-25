extends Area2D
class_name Trap

@export var damage: int = 50

# Popup ayarları
@export var popup_text: String = "I’m not hurt, but I feel exhausted."
@export var popup_duration: float = 2.0

var _popup_done: bool = false

func _ready() -> void:
	# İstersen buradan Layer/Mask veya başka ayarlar da yapabilirsin
	pass


func _on_body_entered(body: Node) -> void:
	# Sadece Player'a zarar vereceğiz
	if body.is_in_group("Player") and body.has_method("take_damage"):
		# Yön için küçük bir hesap (knockback kullanmak istersen)
		var dir: float = sign(body.global_position.x - global_position.x)
		body.take_damage(damage, dir)

	# Popup (sadece ilk tetiklemede)
	if _popup_done:
		return
	if body != null and body.is_in_group("Player"):
		_popup_done = true

		var ui := get_tree().current_scene.get_node_or_null("TrapPopupUI")
		if ui != null and ui.has_method("show_message"):
			ui.show_message(popup_text, popup_duration)
		else:
			push_warning("TrapPopupUI bulunamadı veya show_message() yok!")
