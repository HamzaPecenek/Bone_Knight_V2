extends StaticBody2D

@export var item: InvItem
@export var popup_text: String = "This looks important."
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

		# ✅ POPUP: Sadece Level1 scripti varsa oraya bırak (once logic orada)
		var level := get_tree().current_scene
		if level != null and level.has_method("on_coin_collected_level1"):
			level.on_coin_collected_level1()
		# Diğer levellerde popup istemiyorsun dediğin için burada hiçbir şey yapmıyoruz.

		await get_tree().create_timer(0.1).timeout
		queue_free()
	else:
		push_warning("Player has no collect() method!")

func _on_coin_trigger_body_entered(_body: Node2D) -> void:
	pass
