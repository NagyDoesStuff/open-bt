extends GunPart
class_name AutoGunPart

@export_enum(
	"Auto",
	"Lock-on"
) var mode: String = "Auto"
@export var prediction_factor: float = 10.0

var target: Cluster

func _subready() -> void:
	barrels = get_barrels()
	lasers = get_lasers()
	
	if !disabled and !editor_mode:
		search_for_target()
		if GlobalClass.world:
			GlobalClass.world.entered_arena.connect(search_for_target)

func search_for_target() -> void:
	# Slight delay so the target isnt the same as the one killed.
	await get_tree().process_frame
	 
	var enemies: Array[Cluster] = []
	
	for c in GlobalClass.world.get_clusters():
		if c.team != user.team:
			enemies.append(c)
	
	if enemies.is_empty(): return
	
	target = enemies.pick_random()
	target.killed.connect(search_for_target)

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled: return
	
	if target:
		turn_to(target.global_position + target.velocity * prediction_factor, _delta)
		if can_shoot:
			match mode:
				"Auto": 
					fire_all_barrels()
				"Lock-on" when user == GlobalClass.player_cluster and Input.is_action_pressed(keybind):
					fire_all_barrels()
	else: 
		turn_to(global_position + Vector2.RIGHT.rotated(user.global_rotation), _delta)
