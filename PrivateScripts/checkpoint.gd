extends Node2D

@export var spawnpoint = false
var activated = false

# This function MUST be connected to the "body_entered" signal of your Area2D
func _on_area_2d_body_entered(body):
	# Check if the object touching the flag is the Player
	if body is Player and not activated:
		activate()
		# Tell the player to save this spot
		body.update_respawn_point(global_position)

func activate():
	activated = true
	$AnimationPlayer.play("activation")
