extends Area2D

@export_file("*.tscn") var target_scene: String = "res://Assets/Level_3/Level3.tscn"


@onready var door_sprite: AnimatedSprite2D = $DoorSprite
@onready var trigger_shape: CollisionShape2D = $TriggerShape
@onready var door_light: PointLight2D = $DoorLight

var used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# başlangıç
	door_sprite.play("closed")
	if is_instance_valid(door_light):
		door_light.energy = 0.6  # loş ışık

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if not body.is_in_group("Player"):
		return

	used = true

	# Bir daha tetiklenmesin
	monitoring = false
	if is_instance_valid(trigger_shape):
		trigger_shape.disabled = true

	# Kapı açılırken ışık parlasın
	door_sprite.play("open")
	if is_instance_valid(door_light):
		var t := create_tween()
		t.tween_property(door_light, "energy", 2.0, 0.30)

	# animasyon bitsin
	await door_sprite.animation_finished

	# Teleport FX'nin kapıda çıkması için from_pos gönderelim
	var from_pos := (body as Node2D).global_position
	LevelManager.change_level(target_scene, "SpawnPoint", from_pos)
