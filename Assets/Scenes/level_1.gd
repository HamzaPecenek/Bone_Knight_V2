extends Node2D

@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	# Oyun başı tutorial
	if ui and ui.has_method("show_start_tutorial"):
		ui.show_start_tutorial()
