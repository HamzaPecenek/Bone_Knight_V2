extends State

func enter():
	super.enter()
	owner.set_physics_process(true)
	animation_player.play("idle")
	
func exit():
	super.exit()
	owner.set_physics_process(false)
	
func transition():
	var distance = owner.direction.length()
	if distance < 45:
		get_parent().change_state("MeeleAttack")
	elif distance > 130:
		var chance = randi() %2
		match chance:
			0:
				get_parent().change_state("Missile")
			1:
				get_parent().change_state("LaserBeam")
