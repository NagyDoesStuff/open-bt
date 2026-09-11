extends Camera2D
class_name DynamicCamera

var target_zoom: Vector2 = Vector2.ONE
var anchor: Node2D:
	set(value):
		anchor = value
		if anchor is Cluster:
			target_zoom = Vector2.ONE - Vector2.ONE * ((anchor.cluster_class - 1) * 0.075)
var static_cam: bool = false

func _ready() -> void:
	position_smoothing_speed = 20.0
	position_smoothing_enabled = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_cam"):
		static_cam = !static_cam
	
	if static_cam:
		zoom = lerp(zoom, target_zoom * 0.5, _delta * 3)
		global_position = GlobalClass.current_arena.global_position
	elif anchor: 
		global_position = anchor.global_position
		zoom = lerp(zoom, target_zoom, _delta * 3)
