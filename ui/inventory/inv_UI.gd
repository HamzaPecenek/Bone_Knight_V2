extends Control

@export var inv: Resource  # Inspector’dan playerinv.tres sürükle-bırak

@onready var dim: ColorRect = $Dim
@onready var grid: GridContainer = $Center/NinePatchRect/GridContainer
@onready var slots: Array = []

var is_open := false

func _ready() -> void:
	# Pause olsa bile UI çalışsın (ESC vb. alsın)
	process_mode = Node.PROCESS_MODE_ALWAYS

	slots = grid.get_children()

	close()
	update_slots()

func _unhandled_input(event: InputEvent) -> void:
	# ESC ile kapat
	if is_open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func update_slots() -> void:
	if inv == null:
		return

	for i in range(min(slots.size(), inv.slots.size())):
		slots[i].update(inv.slots[i])

func open() -> void:
	visible = true
	dim.visible = true
	is_open = true

	# oyun dursun
	get_tree().paused = true

	# mouse görünsün
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> void:
	visible = false
	dim.visible = false
	is_open = false

	# oyun devam
	get_tree().paused = false


func toggle() -> void:
	if is_open:
		close()
	else:
		open()
