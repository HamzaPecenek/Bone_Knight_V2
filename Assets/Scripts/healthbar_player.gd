extends ProgressBar
class_name HealthBarPlayer

@export var max_health: int = 100

func _ready() -> void:
	min_value = 0
	max_value = max_health
	value = max_health


func set_health(current_health: int) -> void:
	value = clamp(current_health, 0, max_health)


func reset_health() -> void:
	value = max_health
