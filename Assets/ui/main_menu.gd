extends Control

@export_file("*.tscn") var intro_scene_path: String = "res://AllScenes/intro_screen.tscn"

func _ready() -> void:
	# Menü açıldığında çalışacak şeyler (şimdilik boş)
	pass

# PLAY butonu
func _on_play_button_pressed() -> void:
	# Ekranı karart
	await $FadeLayer.fade_out(0.6)

	# Menü müziğini durdur (varsa)
	if has_node("MusicPlayer") and $MusicPlayer.playing:
		$MusicPlayer.stop()

	# Intro ekranına geç
	if intro_scene_path == "" or not ResourceLoader.exists(intro_scene_path):
		push_error("MainMenu: intro_scene_path bulunamadı: " + str(intro_scene_path))
		return

	get_tree().change_scene_to_file(intro_scene_path)

# SETTINGS butonu
func _on_settings_button_pressed() -> void:
	print("Settings clicked!")
	# İleride ayar penceresi yapınca:
	# $SettingsPanel.visible = true

# QUIT butonu
func _on_quit_button_pressed() -> void:
	print("Quit clicked!")
	get_tree().quit()

# HOW TO PLAY butonu
func _on_how_to_play_button_pressed() -> void:
	print("How To Play clicked!")
	# İleride nasıl oynanır paneli ekleyince:
	# $HowToPlayPanel.visible = true

func _on_music_button_toggled(toggled_on: bool) -> void:
	print("Music toggled: ", toggled_on)

	if toggled_on:
		if not $MusicPlayer.playing:
			$MusicPlayer.play()
	else:
		if $MusicPlayer.playing:
			$MusicPlayer.stop()
