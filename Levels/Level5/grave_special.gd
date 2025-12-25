extends Node2D

@onready var open_grave := $NormalGrave
@onready var closed_grave := $BrokenGrave

func _ready():
	# Boss hayattayken AÇIK mezar görünsün
	open_grave.visible = true
	closed_grave.visible = false

func close_grave():
	# Boss ölünce mezar KAPANSIN
	open_grave.visible = false
	closed_grave.visible = true
