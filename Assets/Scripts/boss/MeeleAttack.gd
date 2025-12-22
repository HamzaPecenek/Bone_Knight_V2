extends State

@onready var meele = $"../../meele"
var can_transition: bool = false

func enter():
	super.enter()
	meele.monitoring = true
	meele.collision_layer = 1
	meele.collision_mask = 1
	
	_connect_signals()
	
	await play_animation("meele_attack")

	meele.monitoring = false        # stop damaging after meele attack ends
	can_transition = true

func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished
	
func _connect_signals():
	if not meele.body_entered.is_connected(_on_meele_body_entered):
		meele.body_entered.connect(_on_meele_body_entered)

func _on_meele_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(10)   # laser damage

func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
