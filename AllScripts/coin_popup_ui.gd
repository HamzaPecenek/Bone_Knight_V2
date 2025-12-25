extends CanvasLayer
class_name CoinPopupUI

@export var default_duration: float = 2.0
@onready var text_label: Label = $Text

# ✅ Metinleri tek yerden yönet (Dictionary: key -> text)
@export var texts: Dictionary = {
	"important": "This looks important."
}

func _ready() -> void:
	layer = 120
	text_label.visible = false

func show_message(msg: String, duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = default_duration

	text_label.text = msg
	text_label.visible = true

	await get_tree().create_timer(duration).timeout
	text_label.visible = false

# ✅ Yeni kullanım: KEY ile göster
func show_key(key: String, duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = default_duration

	var msg: String = String(texts.get(key, key)) # bulunamazsa key'i yazar
	await show_message(msg, duration)
