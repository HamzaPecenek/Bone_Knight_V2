extends CanvasLayer

# İstersen Inspector’dan da atanabilsin
@export var fade_rect_path: NodePath = NodePath("FadeRect")

@onready var rect: ColorRect = null
var _tween: Tween = null

func _ready() -> void:
	rect = _resolve_rect()

	if rect == null:
		push_error("FadeLayer: ColorRect bulunamadı. FadeRect adı/konumu yanlış veya sahnede ColorRect yok.")
		return

	# Başlangıç: şeffaf
	rect.visible = true
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_alpha(0.0)

func _resolve_rect() -> ColorRect:
	# 1) Önce export path ile dene
	if fade_rect_path != NodePath("") and has_node(fade_rect_path):
		var n = get_node(fade_rect_path)
		if n is ColorRect:
			return n as ColorRect

	# 2) "FadeRect" adıyla dene (senin eski kullanımın)
	var by_name := get_node_or_null("FadeRect")
	if by_name is ColorRect:
		return by_name as ColorRect

	# 3) Çocuklarda ilk ColorRect'i ara (en sağlam fallback)
	for child in get_children():
		if child is ColorRect:
			return child as ColorRect

	return null

func _kill_tween() -> void:
	if _tween != null and is_instance_valid(_tween):
		_tween.kill()
	_tween = null

func _set_alpha(a: float) -> void:
	if rect == null:
		return
	var c := rect.color
	c.a = clampf(a, 0.0, 1.0)
	rect.color = c

func fade_out(duration: float = 0.35) -> void:
	# ✅ rect yoksa kilitleme; direkt dön
	if rect == null:
		return

	_kill_tween()
	rect.visible = true

	_tween = create_tween()
	_tween.tween_property(rect, "color:a", 1.0, duration)
	await _tween.finished

func fade_in(duration: float = 0.35) -> void:
	if rect == null:
		return

	_kill_tween()
	rect.visible = true

	_tween = create_tween()
	_tween.tween_property(rect, "color:a", 0.0, duration)
	await _tween.finished

	rect.visible = false
