extends CanvasLayer

@onready var rect := get_node_or_null("FadeRect") as ColorRect


func _ready() -> void:
	if rect == null:
		push_error("FadeLayer: FadeRect bulunamadı. Script yanlış node'a takılı veya runtime'da FadeRect yok.")
		return

	rect.visible = true
	var c := rect.color
	c.a = 0.0
	rect.color = c
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func fade_out(duration: float = 0.35) -> void:
	if rect == null: return
	rect.visible = true
	var t := create_tween()
	t.tween_property(rect, "color:a", 1.0, duration)
	await t.finished

func fade_in(duration: float = 0.35) -> void:
	if rect == null: return
	var t := create_tween()
	t.tween_property(rect, "color:a", 0.0, duration)
	await t.finished
	rect.visible = false
	
