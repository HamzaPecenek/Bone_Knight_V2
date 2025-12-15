extends AnimatableBody2D
class_name MovingPlatform

@export var speed: float = 120.0

# Başlangıç noktasına göre offsetler
@export var offset_a: Vector2 = Vector2.ZERO
@export var offset_b: Vector2 = Vector2(300, 0)

@export var wait_time: float = 0.3

var start_pos: Vector2
var point_a: Vector2
var point_b: Vector2

var going_to_b := true
var wait_left := 0.0

func _ready() -> void:
	start_pos = global_position
	point_a = start_pos + offset_a
	point_b = start_pos + offset_b

func _physics_process(delta: float) -> void:
	if wait_left > 0.0:
		wait_left -= delta
		return

	var target := point_b if going_to_b else point_a
	var step := speed * delta

	# move_toward: çarpışma takılması olmadan hedefe gider
	global_position = global_position.move_toward(target, step)

	# hedefe ulaştı mı?
	if global_position.distance_to(target) < 1.0:
		going_to_b = not going_to_b
		wait_left = wait_time
