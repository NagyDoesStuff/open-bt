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
	for x in range(split_amount):
		var split_result: Projectile = split_into.instantiate()
		split_result.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * split_radius * scale
		split_result.global_rotation = x * (TAU / split_amount)
		split_result.team = user.team
		split_result.velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(min_split_velocity, max_split_velocity)
		GlobalClass.world.add_child(split_result)
