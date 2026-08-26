extends Controller
class_name AIController

@onready var target: Cluster = GlobalClass.player_cluster
var target_detection_radius: float = 9999.0
var target_detection_area: Area2D = Area2D.new()
var analyze_targets_frequency: float = 1.0

var min_freq: float = 1.0
var max_freq: float = 2.0
var turn_dir: int = 0
var min_turn_time_ratio: float = 0.25
var max_turn_time_ratio: float = 0.5
var run_to_center_margin: float = 100.0
var run_turn_rate_mult: float = 2.0

func _ready() -> void:
	add_child(target_detection_area)
	
	var col: CollisionShape2D = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = target_detection_radius
	target_detection_area.add_child(col)
	
	var analysis_timer: Timer = Timer.new()
	analysis_timer.wait_time = analyze_targets_frequency
	analysis_timer.autostart = true
	analysis_timer.timeout.connect(target_analysis)
	add_child(analysis_timer)
	
	_subready()

func target_analysis() -> void:
	var valid_targets: Array[Cluster] = []
	for a in target_detection_area.get_overlapping_areas():
		if a is Cluster and a.team != user.team:
			valid_targets.append(a)
	target = GlobalClass.get_closest_or_farthest(user, valid_targets, true)

func in_avoid_center_margin() -> bool:
	if GlobalClass.ESTIMATED_ARENA_RADIUS * GlobalClass.current_arena.scale.length() / 2 - run_to_center_margin > user.dist_from_center:
		return true
	else:
		return false
