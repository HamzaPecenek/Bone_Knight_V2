extends Node

var next_spawn_name: String = "SpawnPoint"
const TELEPORT_FX: PackedScene = preload("res://Scripts/Teleport/teleport_fx.tscn")

func _spawn_fx(pos: Vector2) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var fx: Node2D = TELEPORT_FX.instantiate() as Node2D
	scene.add_child(fx)
	fx.global_position = pos
	if fx.has_method("play_and_free"):
		fx.call("play_and_free")

func change_level(scene_path: String, spawn_name: String = "SpawnPoint", from_pos: Vector2 = Vector2.INF) -> void:
	next_spawn_name = spawn_name

	# Kapı tarafında efekt
	if from_pos != Vector2.INF:
		_spawn_fx(from_pos)

	# FadeLayer (autoload) al
	var fade: Node = get_node_or_null("/root/FadeLayer")

	# Fade out
	if fade != null and fade.has_method("fade_out"):
		await fade.call("fade_out", 0.35)

	# Sahne değiştir
	var err: int = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Sahne değişmedi! err=" + str(err) + " path=" + scene_path)
		return

	# Yeni sahne otursun
	await get_tree().process_frame
	await get_tree().process_frame  # (bazı projelerde 2 frame daha stabil)

	# Player'ı bul ve spawn'a koy
	var player: Node2D = get_tree().get_first_node_in_group("Player") as Node2D
	if player != null:
		place_player(player)
		_spawn_fx(player.global_position)

	# Fade in
	if fade != null and fade.has_method("fade_in"):
		await fade.call("fade_in", 0.35)

func place_player(player: Node2D) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var sp: Node = scene.get_node_or_null(next_spawn_name)
	if sp == null:
		sp = scene.get_node_or_null("SpawnPoint")

	if sp != null and sp is Node2D:
		player.global_position = (sp as Node2D).global_position
	else:
		push_warning("SpawnPoint bulunamadı: " + next_spawn_name)
