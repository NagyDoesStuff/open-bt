extends Camera2D
class_name DynamicCamera

var anchor: Node2D
var static_cam: bool = false

func _ready() -> void:
	position_smoothing_speed = 20.0
	position_smoothing_enabled = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_cam"):
		static_cam = !static_cam
	
	if static_cam:
		zoom = lerp(zoom, Vector2.ONE * 0.5, _delta * 3)
	elif anchor: 
		global_position = anchor.global_position
		zoom = lerp(zoom, Vector2.ONE, _delta * 3)
