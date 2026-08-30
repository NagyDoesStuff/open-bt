extends AIController
class_name SkittishAI

var run_from_target_margin: float = 400.0

func _process(_delta: float) -> void:
	user.velocity = lerp(
		user.velocity, 
		Vector2.from_angle(user.global_rotation) * user.speed,
		_delta * user.acceleration
	)
	
	if !user.controller.target or !GlobalClass.current_arena: return
	
	var target_angle: float = 0.0
	if in_avoid_center_margin():
		target_angle = (GlobalClass.current_arena.global_position - user.global_position).angle()
	elif in_run_from_target_margin():
		target_angle = (user.global_position - user.controller.target.global_position).angle()
	else:
		target_angle = (user.controller.target.global_position - user.global_position).angle() + PI / 2
		
	user.global_rotation = rotate_toward(
		user.global_rotation,
		target_angle,
		_delta * user.turn_rate
	)

func in_run_from_target_margin() -> bool:
	if user.global_position.distance_to(user.controller.target.global_position) < run_from_target_margin:
		return true
	else:
		return false
