extends Area2D

@export var move_distance: float = 120.0   # sağ-sol mesafe
@export var move_speed: float = 80.0       # hız

var start_pos: Vector2
var direction := 1

func _ready() -> void:
	start_pos = global_position
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	global_position.x += direction * move_speed * delta

	if global_position.x >= start_pos.x + move_distance:
		direction = -1
	elif global_position.x <= start_pos.x - move_distance:
		direction = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(body.max_health)  # anında öl
