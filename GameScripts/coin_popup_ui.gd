extends CanvasLayer
class_name CoinPopupUI

@export var default_duration: float = 2.0
@onready var text_label: Label = $Text

@export var texts: Dictionary = {
	"important": "This looks important."
}

var _hide_id: int = 0
var _shown_once: Dictionary = {}  # once_id -> true

func _ready() -> void:
	layer = 120
	if is_instance_valid(text_label):
		text_label.visible = false
	else:
		push_error("CoinPopupUI: 'Text' isimli Label bulunamadı!")

func show_message(msg: String, duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = default_duration

	if not is_instance_valid(text_label):
		push_error("CoinPopupUI: Text label yok (node adı 'Text' mi?).")
		return

	_hide_id += 1
	var my_id := _hide_id

	text_label.text = msg
	text_label.visible = true

	await get_tree().create_timer(duration).timeout

	if my_id != _hide_id:
		return

	text_label.visible = false

func show_key(key: String, duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = default_duration

	var msg: String = String(texts.get(key, key))
	await show_message(msg, duration)

func show_key_once(once_id: String, key: String, duration: float = -1.0) -> void:
	if _shown_once.has(once_id):
		return
	_shown_once[once_id] = true
	await show_key(key, duration)

func show_message_once(once_id: String, msg: String, duration: float = -1.0) -> void:
	if _shown_once.has(once_id):
		return
	_shown_once[once_id] = true
	await show_message(msg, duration)

func reset_once_cache() -> void:
	_shown_once.clear()
