extends Node2D
class_name State

@onready var debug = owner.find_child("debug")
@onready var player = owner.get_parent().find_child("Player")
@onready var animation_player = owner.find_child("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false) #turn off phys proc
	
func enter(): # activate phys when entered to a state
	set_physics_process(true) 
	
func exit(): #turn of phys when exited from a state
	set_physics_process(false)
	
func transition(): # condition of switching between states
	pass
	
func _physics_process(_delta): #transitions will be running on phys proc
	transition()
	debug.text = name
# Called every frame. 'delta' is the elapsed time since the previous frame.
