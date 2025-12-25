extends Node2D

@export var message: String = "Korkma… karanlık geçici."
@export var show_time: float = 3.0

@onready var label: Label = $CanvasLayer/Label
@onready var area: Area2D = $Area2D

func _ready():
	label.visible = false
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		label.text = message
		label.visible = true
		await get_tree().create_timer(show_time).timeout
		label.visible = false
		
func _process(delta):
	position.y += sin(Time.get_ticks_msec() / 300.0) * 0.15
