extends Control

@export_file("*.tscn") var intro_scene_path: String = "res://GameScenes/intro_screen.tscn"

func _ready() -> void:
	pass

func _on_play_button_pressed() -> void:
	# Fade (FadeLayer düzgünse await edilebilir)
	if has_node("FadeLayer") and $FadeLayer.has_method("fade_out"):
		await $FadeLayer.fade_out(0.6)

	# Menü müziğini durdur
	if has_node("MusicPlayer") and $MusicPlayer.playing:
		$MusicPlayer.stop()

	# Intro ekranına geç
	if intro_scene_path == "" or not ResourceLoader.exists(intro_scene_path):
		push_error("MainMenu: intro_scene_path bulunamadı: " + str(intro_scene_path))
		return

	get_tree().change_scene_to_file(intro_scene_path)

func _on_settings_button_pressed() -> void:
	print("Settings clicked!")

func _on_quit_button_pressed() -> void:
	print("Quit clicked!")
	get_tree().quit()

func _on_how_to_play_button_pressed() -> void:
	print("How To Play clicked!")

func _on_music_button_toggled(toggled_on: bool) -> void:
	print("Music toggled: ", toggled_on)
	if toggled_on:
		if not $MusicPlayer.playing:
			$MusicPlayer.play()
	else:
		if $MusicPlayer.playing:
			$MusicPlayer.stop()
