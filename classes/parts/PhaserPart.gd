extends Part
class_name PhaserPart

var invisible: bool = true
@export var visibility_uptime: float = 4.0
@export var invisibility_uptime: float = 4.0
@export var transition_time: float = 1.0

var phase_timer: Timer = Timer.new()

func _subready() -> void:
	if editor_mode or disabled: return
	
	# Delay so the cluster fade-in isn't interupted.
	await get_tree().create_timer(1.0).timeout
	
	phase_timer.timeout.connect(toggle_phase)
	phase_timer.autostart = true
	add_child(phase_timer)
	
	toggle_phase()

func toggle_phase() -> void:
	invisible = !invisible
	if !invisible:
		create_tween().tween_property(user, "modulate:a", 0.0, transition_time)
		phase_timer.start(invisibility_uptime)
	else:
		create_tween().tween_property(user, "modulate:a", 1.0, transition_time)
		phase_timer.start(visibility_uptime)
