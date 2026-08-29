extends Part
class_name TurretClonerPart

@export var delay_before_cloning: float = 3.0
@export var fade_time: float = .5
@export var transform_time_per_gp: float = 2.0

func _subready() -> void:
	if disabled or !user.enabled or editor_mode: return
	
	get_tree().create_timer(delay_before_cloning).timeout.connect(clone)

func clone() -> void:
	# Get valid targets.
	var valid_targets: Array[Cluster] = []
	for c in GlobalClass.world.get_clusters():
		if c.team != user.team:
			valid_targets.append(c)
	
	# Select random target.
	var target_cluster: Cluster = valid_targets.pick_random()
	
	# Get valid parts (GunParts).
	var valid_parts: Array[GunPart] = []
	for p in target_cluster.get_parts():
		if p is GunPart:
			valid_parts.append(p)
	
	# Sort valid parts array to get the gun with most GP usage.
	valid_parts.sort_custom(func (a, b) -> bool: return a.gp_usage > b.gp_usage)
	var gun_with_best_gp: GunPart = valid_parts[0]
	
	# Duplicate gun and add it to the tree.
	var dupe: GunPart = gun_with_best_gp.duplicate()
	user.add_child(dupe)
	dupe.global_position = global_position
	dupe.global_rotation = user.global_rotation
	dupe.modulate.a = 0.0
	dupe.disabled = true
	dupe.move_to_front()
	
	# Transformation animation.
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	await tween.tween_property(dupe, "modulate:a", 1.0, dupe.gp_usage * transform_time_per_gp).finished
	
	# Enable gun.
	dupe.disabled = false
