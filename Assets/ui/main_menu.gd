extends Control


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

	# Level 1'e geç
	get_tree().change_scene_to_file("res://Assets/Scenes/Level1.tscn")


# SETTINGS butonu
func _on_settings_button_pressed() -> void:
	print("Settings clicked!")
	# İleride ayar penceresi yapınca:
	# $SettingsPanel.visible = true
	# gibi bir şey ekleyebilirsin.


# QUIT butonu
func _on_quit_button_pressed() -> void:
	print("Quit clicked!")
	get_tree().quit()


# HOW TO PLAY butonu
func _on_how_to_play_button_pressed() -> void:
	print("How To Play clicked!")
	# İleride nasıl oynanır paneli ekleyince:
	# $HowToPlayPanel.visible = true
	# şeklinde açıp kapatabilirsin.



func _on_music_button_toggled(toggled_on: bool) -> void:
	print("Music toggled: ", toggled_on)

	if toggled_on:
		# Eğer zaten çalmıyorsa başlat
		if not $MusicPlayer.playing:
			$MusicPlayer.play()
	else:
		# Çalıyorsa durdur
		if $MusicPlayer.playing:
			$MusicPlayer.stop()
