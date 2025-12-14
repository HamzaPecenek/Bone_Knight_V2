extends State

@onready var laser_area = $"../../Pivot/LaserArea"
@onready var pivot = $"../../Pivot"
var can_transition: bool = false

func enter():
	super.enter()
	laser_area.monitoring = true         # enable damage
	laser_area.collision_layer = 1
	laser_area.collision_mask = 1

	_connect_signals()
	
	await play_animation("laser_cast")
	await play_animation("laser")
	
	laser_area.monitoring = false        # stop damaging after laser ends
	#_laser_damage()
	can_transition = true

func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished

func set_target():
	pivot.rotation = (owner.direction - pivot.position).angle()
	
func _connect_signals():
	if not laser_area.body_entered.is_connected(_on_laser_area_body_entered):
		laser_area.body_entered.connect(_on_laser_area_body_entered)


func _on_laser_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(15)   # laser damage

func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")
			
