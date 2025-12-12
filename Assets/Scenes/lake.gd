extends Node2D

@export var interact_text: String = "It's like the lake is trying to tell me something."

var player_inside := false

func _ready() -> void:
	var ui := get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.hide_f_prompt()

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		var ui := get_tree().current_scene.get_node_or_null("UI")
		if ui:
			ui.hide_f_prompt()  # F'ye basınca prompt gitsin
			ui.show_interact_text(interact_text, 3.5)  # asıl credit yazısı çıksın

# InteractArea -> body_entered (Signal Lake'e bağlı olmalı!)
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_inside = true
		var ui := get_tree().current_scene.get_node_or_null("UI")
		if ui:
			ui.show_f_prompt(5.0)

# InteractArea -> body_exited (Signal Lake'e bağlı olmalı!)
func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_inside = false
		var ui := get_tree().current_scene.get_node_or_null("UI")
		if ui:
			ui.hide_f_prompt()
