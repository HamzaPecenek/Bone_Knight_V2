extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(slot: InvSlot) -> void:
	if slot == null or slot.item == null:
		item_visual.visible = false
		amount_text.visible = false
		amount_text.text = ""
		return

	item_visual.visible = true
	item_visual.texture = slot.item.texture

	# 1 ise yazma, 2+ ise yaz
	if slot.amount <= 1:
		amount_text.visible = false
		amount_text.text = ""
	else:
		amount_text.visible = true
		amount_text.text = str(slot.amount)
