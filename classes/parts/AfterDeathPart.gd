extends Part
class_name AfterDeathPart

@export var split_into: PackedScene
@export var split_radius: float = 10.0
@export var split_amount: int = 1
@export var min_split_velocity: float = 10.0
@export var max_split_velocity: float = 20.0

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	user.killed.connect(split)

func split() -> void:
	if !split_into: return
	var split_result: Node2D = split_into.instantiate()
	if split_result is Projectile:
		for x in range(split_amount):
			var split_dupe: Projectile = split_result.duplicate()
			split_dupe.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * split_radius * scale
			split_dupe.global_rotation = x * (TAU / split_amount)
			split_dupe.team = user.team
			split_dupe.velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(min_split_velocity, max_split_velocity)
			GlobalClass.world.call_deferred("add_child", split_dupe)
	elif split_result is Cluster:
		for x in range(split_amount):
			var split_dupe: Cluster = split_result.duplicate()
			split_dupe.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * split_radius * scale
			split_dupe.global_rotation = x * (TAU / split_amount)
			split_dupe.team = user.team
			split_dupe.velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(min_split_velocity, max_split_velocity)
			GlobalClass.world.call_deferred("add_child", split_dupe) 
