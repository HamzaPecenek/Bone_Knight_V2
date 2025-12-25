extends Node2D

@onready var p: GPUParticles2D = $Particles

func play_and_free() -> void:
	p.emitting = true
	var t: SceneTreeTimer = get_tree().create_timer(p.lifetime + 0.2)
	await t.timeout
	queue_free()
