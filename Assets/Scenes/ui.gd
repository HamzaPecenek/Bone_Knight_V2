extends CanvasLayer

@onready var tutorial_label: Label = get_node_or_null("TutorialLabel")
@onready var interact_label: Label = get_node_or_null("InteractLabel")
@onready var f_label: Label = get_node_or_null("FLabel")

var _f_prompt_id: int = 0

func _ready() -> void:
	if tutorial_label:
		tutorial_label.visible = false
	if interact_label:
		interact_label.visible = false
	if f_label:
		f_label.visible = false

# -------------------------------------------------
# OYUN BAŞI TUTORIAL
func show_start_tutorial() -> void:
	show_tutorial("A / D  →  Movements    |    SPACE  →  Jump", 5.0)

func show_tutorial(text: String, duration: float) -> void:
	if tutorial_label == null:
		return

	tutorial_label.text = text
	tutorial_label.visible = true
	await get_tree().create_timer(duration).timeout
	tutorial_label.visible = false

# -------------------------------------------------
# ETKİLEŞİM YAZISI (göl metni vs.)
func show_interact_text(text: String, duration: float = 3.5) -> void:
	if interact_label == null:
		return

	interact_label.text = text
	interact_label.visible = true
	await get_tree().create_timer(duration).timeout
	interact_label.visible = false

# -------------------------------------------------
# "F: ETKİLEŞİM" PROMPT (5 sn, F'ye basınca iptal)
func show_f_prompt(duration: float = 5.0) -> void:
	if f_label == null:
		return

	_f_prompt_id += 1
	var my_id := _f_prompt_id

	f_label.text = "F: Interaction"
	f_label.visible = true

	await get_tree().create_timer(duration).timeout

	if my_id != _f_prompt_id:
		return

	f_label.visible = false

func hide_f_prompt() -> void:
	_f_prompt_id += 1
	if f_label:
		f_label.visible = false
