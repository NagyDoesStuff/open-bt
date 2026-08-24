extends Part
class_name TeleporterPart

@export_enum("lmb", "space") var keybind: String = "space"
@export var cooldown: float = 10.0
@export var ai_tp_dist: float = 100.0
@export var fx: PackedScene
var can_tp: bool = true

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled: return
	
	if can_tp:
		if user == GlobalClass.player_cluster:
			if Input.is_action_pressed(keybind):
				tp()
		else:
			tp()

func tp() -> void:
	can_tp = false
	
	var before_fx: Node2D = fx.instantiate()
	before_fx.global_position = global_position
	GlobalClass.world.add_child(before_fx)
	
	if user.team == 0:
		user.global_position = get_global_mouse_position()
	else:
		user.global_position += Vector2.from_angle(
			(GlobalClass.player_cluster.global_position - user.global_position).angle()
		) * ((GlobalClass.player_cluster.global_position - user.global_position).length() - ai_tp_dist)
	
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_tp", true))
	
	await get_tree().process_frame
	
	var after_fx: Node2D = fx.instantiate()
	after_fx.global_position = global_position
	GlobalClass.world.add_child(after_fx)
