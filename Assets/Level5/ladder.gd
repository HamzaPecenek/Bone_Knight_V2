extends Area2D

func _physics_process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()

	for b in bodies:
		if b is Player:
			b.on_ladder = true
			return

	# Buraya geldiyse: bu ladder'ın içinde Player yok
	for p in get_tree().get_nodes_in_group("Player"):
		if p is Player:
			p.on_ladder = false
