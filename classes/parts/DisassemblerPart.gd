extends Part
class_name DisassemblerPart

@export_enum(
	"lmb",
	"space"
) var keybind: String = "space"
@export var transition_time: float = 0.5
@export var cooldown: float = 1.0

var active: bool = false:
	set(value):
		if disabled or editor_mode: return
		active = value
		toggle(active)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(keybind):
		active = true
	if Input.is_action_just_released(keybind):
		active = false

func toggle(value) -> void:
	if value:
		disassemble()
	else:
		assemble()

func disassemble() -> void:
	user.monitoring = false
	user.monitorable = false
	user.can_fire = false
	
	var parts: Array[Part] = user.get_parts().duplicate()
	parts.shuffle()
	
	get_tree().create_timer(transition_time + cooldown).timeout.connect(set.bind("mid_transition", false))
	
	var tween: Tween = create_tween().set_parallel(true)
	for p in parts:
		if GlobalClass.dice(1,2):
			tween.tween_property(p, "modulate:a", 0.0, transition_time)
		else:
			tween.tween_property(p, "modulate:a", randf_range(0.5, 1.0), transition_time)

func assemble() -> void:
	user.monitoring = true
	user.monitorable = true
	user.can_fire = true
	
	var tween: Tween = create_tween().set_parallel(true)
	for p in user.get_parts():
		tween.tween_property(p, "modulate:a", 1.0, transition_time)
