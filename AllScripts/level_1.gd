extends Node2D

@onready var tutorial: TutorialUI = $TutorialUI
@onready var inv_ui = $CanvasLayer/Inventory

func _ready() -> void:
	if tutorial:
		tutorial.show_step(0)

func _process(_delta: float) -> void:
	if tutorial == null or tutorial.is_done():
		return

	# STEP 0: move
	if tutorial.get_step() == 0:
		if Input.get_axis("walk_left", "walk_right") != 0:
			tutorial.show_step(1)
		return

	# STEP 1: jump
	if tutorial.get_step() == 1:
		if Input.is_action_just_pressed("jump"):
			tutorial.show_step(2)
		return

	# STEP 2: attack
	if tutorial.get_step() == 2:
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("attack_heavy"):
			tutorial.show_step(3)
		return

	# STEP 3: inventory aç-kapat
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
