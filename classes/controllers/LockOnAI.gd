extends AIController
class_name LockOnAI

var lock_on_offset: Vector2 = Vector2.ZERO
var lock_on_distance: float = 150.0
var change_offset_cooldown: float = 4.0

func _subready() -> void:
	set_offset()

func set_offset() -> void:
	lock_on_offset = Vector2.from_angle(randf_range(0, TAU)) * lock_on_distance * user.cluster_class
	if get_tree(): get_tree().create_timer(change_offset_cooldown).timeout.connect(set_offset)

func _process(_delta: float) -> void:
	if !GlobalClass.current_arena: return
	
	if in_avoid_center_margin() and user.die_to_border:
		user.velocity = lerp(
			user.velocity, 
			Vector2.from_angle(user.global_rotation) * user.speed,
			_delta * user.acceleration
		)
		user.global_rotation = rotate_toward(
			user.global_rotation,
			(GlobalClass.current_arena.global_position - user.global_position).angle(),
			_delta * user.turn_rate * run_turn_rate_mult
		)
	elif target:
		user.velocity = lerp(
			user.velocity, 
			((target.global_position + lock_on_offset) - global_position).normalized() * user.speed,
			_delta * user.acceleration
		)
		user.global_rotation = rotate_toward(
			user.global_rotation,
			(target.global_position - user.global_position).angle(),
			_delta * user.turn_rate
		)
		
