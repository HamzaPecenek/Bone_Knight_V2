extends Area2D

@export var target_scene: String
@export var target_spawn: String = "SpawnPoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		LevelManager.change_level(target_scene, target_spawn)
