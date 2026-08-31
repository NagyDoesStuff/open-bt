extends AIController
class_name FlockingAI

var can_turn: bool = false
var is_mother: bool = false

var init_speed: float

var flock_rotation_offset: float
var rand_flock_arc: float = 0.4

var flock_radius: float = 4000.0
var min_flock_radius_mult: float = 0.8

var mother: Cluster

func _subready() -> void:
	init_speed = user.speed
	flock_radius *= randf_range(min_flock_radius_mult, 1.0)
	flock_rotation_offset = randf_range(-rand_flock_arc, rand_flock_arc)
	ai_cycle()

func ai_cycle() -> void:
	var time: float = randf_range(min_freq, max_freq)
	turn(time)
	if get_tree(): get_tree().create_timer(time).timeout.connect(ai_cycle)
	
	var valid_clusters: Array[Cluster] = []
	for c in GlobalClass.world.get_clusters():
		if c.team == user.team and c.controller is FlockingAI:
			valid_clusters.append(c)
	valid_clusters.shuffle()
	valid_clusters.sort_custom(func (a, b) -> bool: return a.get_used_gp() > b.get_used_gp())
	
	if mother: mother.controller.is_mother = false
	var new_mother: Cluster = valid_clusters[0]
	if new_mother != user:
		mother = new_mother
		mother.controller.is_mother = true

func _process(_delta: float) -> void:
	# Move forward.
	user.velocity = lerp(
		user.velocity, 
		Vector2.from_angle(user.global_rotation) * user.speed,
		_delta * user.acceleration
	)
	
	if !GlobalClass.current_arena: return
	
	if in_avoid_center_margin():
		# Avoid 
		user.speed = init_speed
		user.global_rotation = rotate_toward(
			user.global_rotation,
			(GlobalClass.current_arena.global_position - user.global_position).angle(),
			_delta * user.turn_rate * run_turn_rate_mult
		)
	elif can_turn and in_mother_radius() and mother and !is_mother:
		user.speed = init_speed
		user.global_rotation = rotate_toward(
			user.global_rotation,
			(mother.global_position - user.global_position).angle(),
			_delta * user.turn_rate
		)
	elif can_turn and mother and !is_mother:
		user.speed = mother.speed
		user.global_rotation = rotate_toward(
				user.global_rotation,
				mother.velocity.angle() + flock_rotation_offset,
				_delta * user.turn_rate
			)
	
func turn(duration: float) -> void:
	can_turn = true
	if get_tree(): get_tree().create_timer(duration).timeout.connect(set.bind("can_turn", false))

func in_mother_radius() -> bool:
	if mother and user.global_position.distance_to(mother.global_position) > 300.0:
		return true
	else:
		return false
