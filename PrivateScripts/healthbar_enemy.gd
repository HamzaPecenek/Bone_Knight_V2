extends ProgressBar
class_name HealthBarEnemy

@export var max_health: int = 100

func _ready() -> void:
	apply_max_health(max_health)
	value = max_health

func apply_max_health(new_max: int) -> void:
	max_health = new_max
	min_value = 0
	max_value = max_health
	value = clamp(value, 0, max_health)

func set_health(current_health: int) -> void:
	value = clamp(current_health, 0, max_health)

func reset_health() -> void:
	value = max_health
