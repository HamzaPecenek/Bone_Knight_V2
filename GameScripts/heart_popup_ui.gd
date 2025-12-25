extends CanvasLayer
class_name HeartPopupUI

@export var default_duration: float = 2.0
@onready var text_label: Label = $Text

var _hide_id: int = 0

func _ready() -> void:
	layer = 120
	if is_instance_valid(text_label):
		text_label.visible = false
	else:
		push_error("HeartPopupUI: 'Text' isimli Label bulunamadı!")

func show_message(msg: String, duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = default_duration

	if not is_instance_valid(text_label):
		push_error("HeartPopupUI: Text label yok (node adı 'Text' mi?).")
		return

	_hide_id += 1
	var my_id := _hide_id

	text_label.text = msg
	text_label.visible = true

	await get_tree().create_timer(duration).timeout

	# Bu sırada başka popup gösterildiyse eskisini kapatma
	if my_id != _hide_id:
		return

	text_label.visible = false
