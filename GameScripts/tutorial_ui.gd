extends CanvasLayer
class_name TutorialUI

@export var step_texts: Array[String] = [
	"Welcome!\n\nUse A / D to move.",
	"Great!\n\nPress Space to jump.",
	"Awesome!\n\nUse Left Click to attack.",
	"Good job!\n\nPress I to open the inventory.",
	"You're ready!\n\nHave fun :)"
]

@export var finish_hold: float = 1.5
@export var fade_in_time: float = 0.30
@export var fade_out_time: float = 0.20

@onready var box: Panel = $Box
@onready var label: Label = $Box/MarginContainer/Text

var _step: int = 0
var _done: bool = false
var _finish_scheduled: bool = false
var _tween: Tween

func _ready() -> void:
	visible = true
	layer = 100

	# Box boyut
	if box.custom_minimum_size == Vector2.ZERO:
		box.custom_minimum_size = Vector2(520, 180)
	box.size = box.custom_minimum_size
	box.visible = true

	# Label ayarları
	label.visible = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_center_box()
	get_viewport().size_changed.connect(_center_box)

	# İlk adım
	show_step(0)

	# Fade in
	_fade_in()

func _center_box() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	box.position = (vp - box.size) * 0.5

func show_step(i: int) -> void:
	if _done:
		return
	if step_texts.is_empty():
		return

	_step = clamp(i, 0, step_texts.size() - 1)
	label.text = step_texts[_step]

	visible = true
	box.visible = true
	_center_box()

	# Son step -> otomatik bitir
	if _step == step_texts.size() - 1 and not _finish_scheduled:
		_finish_scheduled = true
		call_deferred("_auto_finish")

func _auto_finish() -> void:
	if _done:
		return
	await get_tree().create_timer(finish_hold).timeout
	finish()

func finish() -> void:
	if _done:
		return
	_done = true
	_fade_out()

func _fade_in() -> void:
	_kill_tween()

	box.modulate.a = 0.0

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)

	_tween.tween_property(box, "modulate:a", 1.0, fade_in_time)

func _fade_out() -> void:
	_kill_tween()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN)

	_tween.tween_property(box, "modulate:a", 0.0, fade_out_time)

	_tween.finished.connect(func():
		visible = false
	)

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = null

func is_done() -> bool:
	return _done

func get_step() -> int:
	return _step

# Player.gd burayı çağırıyor
func on_inventory_toggled(is_open: bool) -> void:
	if _done:
		return

	if _step == 3 and is_open:
		show_step(4)

func on_inventory_closed_with_esc() -> void:
	if _done:
		return

	if _step == 4 and not _finish_scheduled:
		_finish_scheduled = true
		call_deferred("_auto_finish")
