extends Control

@export_file("*.tscn") var next_scene_path := "res://AllScenes/Level4.tscn"

@export var intro_text := "Reaching the goal is becoming harder and harder.\n\nIt feels like the forest is preparing me for what lies ahead.\nI have unseen allies.\n\nFor you.\nI will not give up."

# Fade
@export var fade_in_time := 0.6
@export var fade_out_time := 0.6

# Typewriter
@export var chars_per_second: float = 12.0
@export var extra_hold_after_type: float = 4.0

# Music
@export var play_music: bool = true
@export var music_volume_db: float = -6.0

@onready var black: ColorRect = $Black
@onready var text_label: Label = $Text
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var tween: Tween
var _skipped := false

func _ready() -> void:
	# BLACK
	if is_instance_valid(black):
		black.anchor_left = 0
		black.anchor_top = 0
		black.anchor_right = 1
		black.anchor_bottom = 1
		black.offset_left = 0
		black.offset_top = 0
		black.offset_right = 0
		black.offset_bottom = 0
		black.color = Color.BLACK

	# TEXT (wrap + padding)
	if is_instance_valid(text_label):
		text_label.anchor_left = 0
		text_label.anchor_top = 0
		text_label.anchor_right = 1
		text_label.anchor_bottom = 1

		text_label.offset_left = 120
		text_label.offset_top = 200
		text_label.offset_right = -120
		text_label.offset_bottom = -200

		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# Typewriter başlangıcı
		text_label.text = intro_text
		text_label.visible_characters = 0

	# Müzik (Stream inspector'dan eklenecek)
	if play_music and is_instance_valid(music_player) and music_player.stream != null:
		music_player.volume_db = music_volume_db
		music_player.play()

	# Fade başlangıcı
	modulate.a = 0.0
	_play_intro()

func _play_intro() -> void:
	if tween:
		tween.kill()

	_skipped = false

	var total_chars := intro_text.length()
	var type_duration := 0.0
	if chars_per_second > 0.0:
		type_duration = float(total_chars) / chars_per_second

	tween = create_tween()

	# 1) fade in
	tween.tween_property(self, "modulate:a", 1.0, fade_in_time)

	# 2) typewriter
	if is_instance_valid(text_label):
		tween.tween_property(text_label, "visible_characters", total_chars, type_duration)
	else:
		# Label yoksa yine de bekle
		tween.tween_interval(type_duration)

	# 3) biraz bekle
	tween.tween_interval(extra_hold_after_type)

	# 4) fade out
	tween.tween_property(self, "modulate:a", 0.0, fade_out_time)

	# 5) sahne değiştir
	tween.tween_callback(_go_next)

func _go_next() -> void:
	if _skipped:
		return
	_skipped = true
	get_tree().change_scene_to_file(next_scene_path)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_or_finish()

func _skip_or_finish() -> void:
	# 1. basış: yazıyı anında tamamla
	if is_instance_valid(text_label) and text_label.visible_characters < intro_text.length():
		text_label.visible_characters = intro_text.length()
		return

	# 2. basış: direkt geç
	if tween:
		tween.kill()
	_go_next()
