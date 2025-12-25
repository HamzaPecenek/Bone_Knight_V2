extends Node2D

@onready var tutorial: TutorialUI = $TutorialUI
@onready var inv_ui = $CanvasLayer/Inventory

@onready var coin_popup: CoinPopupUI = get_node_or_null("CanvasLayer/CoinPopupUI") as CoinPopupUI

func _ready() -> void:
	if coin_popup == null:
		coin_popup = get_tree().get_first_node_in_group("CoinPopupUI") as CoinPopupUI

	if coin_popup == null:
		push_warning("Level1: CoinPopupUI bulunamadı!")

	if tutorial:
		tutorial.show_step(0)

func on_coin_collected_level1() -> void:
	if coin_popup == null:
		coin_popup = get_tree().get_first_node_in_group("CoinPopupUI") as CoinPopupUI
		if coin_popup == null:
			push_warning("Level1: CoinPopupUI hala yok.")
			return

	await coin_popup.show_message_once("level1_first_coin", "This looks important.", 2.0)

func _process(_delta: float) -> void:
	if tutorial == null or tutorial.is_done():
		return

	if tutorial.get_step() == 0:
		if Input.get_axis("walk_left", "walk_right") != 0:
			tutorial.show_step(1)
		return

	if tutorial.get_step() == 1:
		if Input.is_action_just_pressed("jump"):
			tutorial.show_step(2)
		return

	if tutorial.get_step() == 2:
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("attack_heavy"):
			tutorial.show_step(3)
		return

	if tutorial.get_step() == 3:
		if inv_ui == null:
			tutorial.show_step(4)
			await get_tree().create_timer(1.2).timeout
			tutorial.finish()
			return

		if inv_ui.visible:
			tutorial.show_step(4)
			await get_tree().create_timer(1.2).timeout
			tutorial.finish()
		return
