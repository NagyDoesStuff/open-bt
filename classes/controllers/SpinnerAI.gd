extends AIController
class_name SpinnerAI

var spin_dir: int = [-1,1].pick_random()

func _process(_delta: float) -> void:
	user.velocity = Vector2.ZERO
	user.global_rotation += user.turn_rate * spin_dir * _delta
