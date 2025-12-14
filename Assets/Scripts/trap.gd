extends Area2D
class_name Trap

@export var damage: int = 50

func _ready() -> void:
	# İstersen buradan Layer/Mask veya başka ayarlar da yapabilirsin
	pass


func _on_body_entered(body: Node) -> void:
	# Sadece Player'a zarar vereceğiz
	if body.is_in_group("Player") and body.has_method("take_damage"):
		# Yön için küçük bir hesap (knockback kullanmak istersen)
		var dir: float = sign(body.global_position.x - global_position.x)
		body.take_damage(damage, dir)
