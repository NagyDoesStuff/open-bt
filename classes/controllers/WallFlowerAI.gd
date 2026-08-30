extends AIController
class_name WallFlowerAI

func _enter_tree() -> void:
	run_to_center_margin *= 0.5

func _process(_delta: float) -> void:
	user.velocity = lerp(
		user.velocity, 
		Vector2.from_angle(user.global_rotation) * user.speed,
		_delta * user.acceleration
	)
	
	if !GlobalClass.current_arena: return
	
	var target_angle: float = 0.0
	if in_avoid_center_margin():
		target_angle = (GlobalClass.current_arena.global_position - user.global_position).angle()
	else:
		target_angle = (GlobalClass.current_arena.global_position - user.global_position).angle() + PI / 2
		
	user.global_rotation = rotate_toward(
		user.global_rotation,
		target_angle,
		_delta * user.turn_rate
	)
